class Node < Formula
  desc "Runs Node.js commands using Bun"
  homepage "https://bun.sh/"
  head "https://github.com/lingyang-kong/homebrew-node-via-bun.git", branch: "main"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    bun_bin = Formula["oven-sh/bun/bun"].opt_bin

    {
      "node" => "bun",
      "npm" => "bun",
      "npx" => "bunx",
    }.each do |shim, target|
      (bin/shim).write <<~EOS
        #!/bin/sh
        exec "#{bun_bin}/#{target}" "$@"
      EOS
    end

    (bin/"corepack").write <<~EOS
      #!/bin/sh
      echo "corepack is not provided by the Bun-backed node shim" >&2
      exit 127
    EOS

    chmod 0755, bin.children
  end

  test do
    %w[node npm npx].each do |command|
      assert_match(/\A\d+\.\d+\.\d+/, shell_output("#{bin}/#{command} --version"))
    end
  end
end
