# frozen_string_literal: true

# Node shim formula backed by Bun
class Node < Formula
  desc "Runs Node.js commands using Bun"
  homepage "https://github.com/lingyang-kong/node-via-bun"
  url "https://github.com/lingyang-kong/node-via-bun/archive/refs/tags/v1.0.0+via-bun1.tar.gz"
  version "1.0.0+via-bun1"
  sha256 "cce86967ad403d53ed49c3abb46cb111846ceeea12d6b715d6f63a33bf707513"
  license "MIT"

  head "https://github.com/lingyang-kong/node-via-bun.git", branch: "main"

  depends_on "oven-sh/bun/bun"

  def install
    multicall_path = libexec / "node-via-bun"

    libexec.install buildpath / "src/npm-version.js"
    (pkgshare / File.dirname(commands_test_path)).install buildpath / commands_test_path
    compile_multicall_binary(multicall_path)
    link_applets(multicall_path)
  end

  def commands_test_path
    "tests/installed-commands.sh"
  end

  def compile_multicall_binary(multicall_path)
    bun_opt_bin = formula_opt_bin("oven-sh/bun/bun")
    cflags = (buildpath / "src/cflags.txt").read.lines.map(&:strip).reject(&:empty?)
    macos_ldflags = %w[-Wl,-dead_strip]
    defines = {
      BUN_PATH:         "#{bun_opt_bin}/bun",
      BUNX_PATH:        "#{bun_opt_bin}/bunx",
      NPM_VERSION_PATH: "#{libexec}/npm-version.js",
    }.map { |name, path| %Q(-D#{name}="#{path}") }

    system ENV.cc, *cflags, *defines,
           buildpath / "src/node-via-bun.c", "--output", multicall_path, *macos_ldflags
  end

  def link_applets(multicall_path)
    bin.mkpath
    %w[node npm npx].each do |name|
      ln multicall_path, bin / name
    end
  end

  test do
    ENV["NODE_VIA_BUN_EXPECT_NODEJS"] = "0"
    system pkgshare / commands_test_path, bin
  end
end
