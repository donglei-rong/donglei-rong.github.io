# frozen_string_literal: true
# Optional Windows entry point; Linux / GitHub Actions use Jekyll normally.
require "rubygems"
require "./scripts/windows-compat"
require "bundler/setup"
load Gem.bin_path("jekyll", "jekyll")
