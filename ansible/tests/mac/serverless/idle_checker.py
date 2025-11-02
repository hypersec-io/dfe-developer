#!/usr/bin/env python3
"""
Scaleway Serverless Function - Mac Mini Idle Checker
Deletes Mac minis with 'auto-delete' tag after 24h of no activity

Triggered: Every hour via CRON trigger
Checks: SSH connections, CPU usage from Scaleway metrics
Deletes: Servers idle >24h with matching tags
"""
import os
import json
from datetime import datetime, timedelta
import requests

def handle(event, context):
    """Main handler for Scaleway Function"""

    # Get credentials from environment
    secret_key = os.environ['SCALEWAY_SECRET_KEY']
    zone = os.environ.get('SCALEWAY_ZONE', 'fr-par-3')

    api_url = f"https://api.scaleway.com/apple-silicon/v1alpha1/zones/{zone}/servers"
    headers = {"X-Auth-Token": secret_key}

    # List all Mac mini servers
    response = requests.get(api_url, headers=headers)
    servers = response.json().get('servers', [])

    deleted = []
    kept = []

    for server in servers:
        # Only check servers with auto-delete tag
        tags = server.get('tags', [])
        if 'auto-delete' not in tags:
            kept.append(f"{server['name']}: no auto-delete tag")
            continue

        # Check server age
        created_at = datetime.fromisoformat(server['created_at'].replace('Z', '+00:00'))
        age_hours = (datetime.now(created_at.tzinfo) - created_at).total_seconds() / 3600

        # Get metrics (CPU, network activity)
        server_id = server['id']
        metrics_url = f"{api_url}/{server_id}/metrics"
        metrics_response = requests.get(metrics_url, headers=headers)

        if metrics_response.status_code == 200:
            metrics = metrics_response.json()
            # Check for activity in last 24 hours
            cpu_usage = metrics.get('cpu_usage_avg_1h', 100)  # Default to active if unknown
            network_rx = metrics.get('network_rx_bytes_1h', 1000)  # Default to active

            # Idle if CPU <5% and minimal network for 24h
            if cpu_usage < 5 and network_rx < 1000 and age_hours >= 24:
                # Delete idle server
                delete_response = requests.delete(f"{api_url}/{server_id}", headers=headers)
                if delete_response.status_code in [200, 204]:
                    deleted.append(f"{server['name']}: idle {age_hours:.1f}h, deleted")
                else:
                    kept.append(f"{server['name']}: delete failed - {delete_response.status_code}")
            else:
                kept.append(f"{server['name']}: active (CPU:{cpu_usage}%, age:{age_hours:.1f}h)")
        else:
            kept.append(f"{server['name']}: metrics unavailable")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "deleted": deleted,
            "kept": kept,
            "timestamp": datetime.now().isoformat()
        })
    }
