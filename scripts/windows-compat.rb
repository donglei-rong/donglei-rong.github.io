# frozen_string_literal: true
# Local Windows compatibility only. Some sandboxed Ruby installations return an
# empty result for drive-absolute Dir.glob patterns while base-relative patterns
# work. Apply the equivalent base form only when that failure is observed.
# No Jekyll output, templates, or dependencies are replaced.
require "rbconfig"

if Gem.win_platform?
  # RubyInstaller can tag its startup paths with the Windows ANSI encoding,
  # even with -EUTF-8. Bundler compares these with UTF-8 paths. Normalize the
  # existing paths before loading Bundler when Ruby lives in a Chinese folder.
  [$LOAD_PATH, $LOADED_FEATURES].each do |paths|
    paths.map! { |path| path.encoding == Encoding::UTF_8 ? path : path.encode(Encoding::UTF_8) }
  end

  libdir = RbConfig::CONFIG["rubylibdir"]
  if Dir.glob(File.join(libdir, "*.rb")).empty? && !Dir.glob("*.rb", base: libdir).empty?
    module WindowsAbsoluteGlob
      def glob(pattern, flags = 0, **options, &block)
        results = Array(pattern).flat_map do |item|
          normalized = item.to_s.tr("\\", "/")
          unless normalized.match?(%r{\A[A-Za-z]:/})
            next super(item, flags, **options)
          end
          wildcard = normalized.index(/[*?\[{]/)
          unless wildcard
            next File.exist?(normalized) ? [normalized] : []
          end
          prefix = normalized[0...wildcard].rpartition("/").first
          prefix += "/" if prefix.match?(/\A[A-Za-z]:\z/)
          tail = normalized.delete_prefix(prefix).sub(%r{\A/}, "")
          super(tail, flags, **options.merge(base: prefix)).map { |match| File.join(prefix, match) }
        end
        return results.each(&block) && nil if block
        results
      end

      def [](*patterns, **options)
        glob(patterns, options.delete(:flags) || 0, **options)
      end
    end
    Dir.singleton_class.prepend(WindowsAbsoluteGlob)
  end
end

