#!/usr/bin/env bats
# 03-lib-functions.bats - Unit tests for lib.sh functions

setup() {
    # Source lib.sh for testing
    SCRIPT_DIR="$(dirname "$BATS_TEST_DIRNAME")"
    source "$SCRIPT_DIR/lib.sh"
}

# ============================================================================
# OUTPUT FUNCTIONS
# ============================================================================
@test "print_info outputs correctly" {
    run print_info "test message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"INFO"*"test message"* ]]
}

@test "print_error outputs to stderr" {
    run print_error "error message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ERROR"*"error message"* ]]
}

@test "print_warning outputs correctly" {
    run print_warning "warning message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"WARN"*"warning message"* ]]
}

@test "print_success outputs correctly" {
    run print_success "success message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"SUCCESS"*"success message"* ]]
}

@test "print_header formats correctly" {
    skip "print_header function removed from lib.sh"
}

# ============================================================================
# SYSTEM DETECTION
# ============================================================================
@test "is_fedora detects Fedora correctly" {
    if [[ -f /etc/fedora-release ]]; then
        is_fedora
    else
        ! is_fedora
    fi
}

@test "is_installed detects bash" {
    is_installed bash
}

@test "is_installed fails for non-existent command" {
    ! is_installed this_command_does_not_exist_xyz123
}

@test "detect_vm returns valid exit code" {
    run detect_vm
    # Should return 0 or 1, not crash
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "get_vm_type returns string" {
    run get_vm_type
    [ "$status" -eq 0 ]
    [[ -n "$output" ]]
}

@test "is_container detects container environment" {
    if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
        is_container
    else
        ! is_container
    fi
}

# ============================================================================
# VERSION MANAGEMENT
# ============================================================================
@test "version_gt compares versions correctly" {
    version_gt "2.0.0" "1.0.0"
    version_gt "1.1.0" "1.0.9"
    version_gt "10.0.0" "9.9.9"
}

@test "version_gt fails for equal versions" {
    ! version_gt "1.0.0" "1.0.0"
}

@test "version_gt fails when first is lower" {
    ! version_gt "1.0.0" "2.0.0"
    ! version_gt "1.9.9" "2.0.0"
}

# ============================================================================
# FILE OPERATIONS
# ============================================================================
@test "create_directory creates directory" {
    local test_dir="/tmp/bats-test-$$"
    create_directory "$test_dir"
    [[ -d "$test_dir" ]]
    rmdir "$test_dir"
}

@test "file_contains detects string in file" {
    local test_file="/tmp/bats-test-$$.txt"
    echo "hello world" > "$test_file"
    file_contains "$test_file" "hello"
    ! file_contains "$test_file" "goodbye"
    rm -f "$test_file"
}

@test "append_if_missing adds new content" {
    local test_file="/tmp/bats-test-$$.txt"
    echo "line1" > "$test_file"
    append_if_missing "$test_file" "line2"
    file_contains "$test_file" "line2"
    rm -f "$test_file"
}

@test "append_if_missing doesn't duplicate content" {
    local test_file="/tmp/bats-test-$$.txt"
    echo "line1" > "$test_file"
    append_if_missing "$test_file" "line1" || true
    # Should only have one occurrence
    [[ $(grep -c "line1" "$test_file") -eq 1 ]]
    rm -f "$test_file"
}

@test "backup_file creates timestamped backup" {
    local test_file="/tmp/bats-test-$$.txt"
    echo "content" > "$test_file"
    backup_file "$test_file"
    # Check backup was created
    ls "$test_file".backup.* &>/dev/null
    rm -f "$test_file" "$test_file".backup.*
}

# ============================================================================
# VALIDATION HELPERS
# ============================================================================
@test "is_root detects root correctly" {
    if [[ $EUID -eq 0 ]]; then
        is_root
    else
        ! is_root
    fi
}

@test "is_set detects set variables" {
    local test_var="value"
    is_set "$test_var"
    ! is_set ""
    ! is_set
}

@test "is_empty detects empty variables" {
    local empty_var=""
    is_empty "$empty_var"
    is_empty ""
    ! is_empty "value"
}

# ============================================================================
# PATH HELPERS
# ============================================================================
@test "is_absolute_path detects absolute paths" {
    is_absolute_path "/usr/bin"
    is_absolute_path "/tmp/test"
    ! is_absolute_path "relative/path"
    ! is_absolute_path "./local"
}

@test "get_script_dir returns directory" {
    run get_script_dir
    [ "$status" -eq 0 ]
    [[ -d "$output" ]]
}