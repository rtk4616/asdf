#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
}

teardown() {
  clean_asdf_dir
}

@test "plugin_add command with no URL specified adds a plugin using repo" {
  run asdf plugin-add "elixir"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "elixir" ]
}

@test "plugin_add command with URL specified adds a plugin using repo" {
  install_mock_plugin_repo "dummy"

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"
  [ "$status" -eq 0 ]

  run asdf plugin-list
  # whitespace between 'elixir' and url is from printf %-15s %s format
  [ "$output" = "dummy" ]
}

@test "plugin_add command with no URL specified fails if the plugin doesn't exist" {
  run asdf plugin-add "does-not-exist"
  [ "$status" -eq 1 ]
  echo "$output" | grep "plugin does-not-exist not found in repository"
}

@test "plugin_add command executes post-plugin-add script" {
  install_mock_plugin_repo "dummy"

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"

  [ "$output" = "plugin-add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy" ]
}

@test "plugin_add command executes configured pre hook (generic)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD dummy
plugin-add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured pre hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="ADD
plugin-add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (generic)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_plugin_add = echo ADD ${@}
EOM

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin-add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD dummy"
  [ "$output" = "${expected_output}" ]
}

@test "plugin_add command executes configured post hook (specific)" {
  install_mock_plugin_repo "dummy"

  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_plugin_add_dummy = echo ADD
EOM

  run asdf plugin-add "dummy" "${BASE_DIR}/repo-dummy"

  local expected_output="plugin-add path=${ASDF_DIR}/plugins/dummy source_url=${BASE_DIR}/repo-dummy
ADD"
  [ "$output" = "${expected_output}" ]
}
