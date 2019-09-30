# frozen_string_literal: true

require 'sass'
require 'tempfile'
require 'json'

Jekyll::Hooks.register(:site, :post_write) do |site|
  next if ENV['JEKYLL_ENV'] != 'production'

  print 'UnCSS'.rjust(18), ': '
  config = site.config['uncss'] || {}

  unless config.key?('stylesheets')
    raise 'Missing option \'uncss.stylesheets\'!'
  end

  # Prefix files with site path
  files = config.fetch('files', ['**/*.html']).collect do |file|
    File.join(site.dest, file)
  end

  # Produce UnCSS instance
  uncss = Jekyll::UnCSS.new(files,
                            htmlroot: site.dest,
                            ignore: config['ignore'],
                            media: config['media'],
                            timeout: config['timeout'],
                            banner: config['banner'])

  # Process each given stylesheet
  config['stylesheets'].each do |stylesheet|
    uncss.process(stylesheet, config['compress']) do |output|
      File.open(File.join(site.dest, stylesheet), 'w') do |fd|
        fd.write(output) # Writes new css back to disk
      end
    end
  end

  print 'Complete, processed ', config['stylesheets'].length, ' css file(s)'
  puts
end

module Jekyll
  # Handles the stripping of unnessissary css.
  class UnCSS
    class Error < StandardError; end

    def initialize(files, **options)
      @files = [files].flatten
      @options = options.compact
    end

    def process(css, compress)
      make_config(css)
      result = uncss(compress)

      yield(result) if block_given?
      result
    ensure
      cleanup_config
    end

    private

    def uncss(compress)
      path = @temp_file.path
      files = @files.join("' '")
      result = `uncss --uncssrc '#{path}' '#{files}' 2>&1`
      result = strip_banner(result)
      result = Sass.compile(result, style: :compressed) if compress
      result.strip!
      result << "\n"
    rescue Error => e
      raise Error, "uncss failed: #{e} :: #{result}"
    end

    def strip_banner(result)
      return result unless @options[:banner] == false
      return result unless result.start_with?('/*** uncss> filename: ')

      result.partition('***/').last
    end

    def make_config(css)
      options = @options.clone

      # uncss treats absolute stylesheet paths as relative to htmlroot
      options[:stylesheets] = [(css.start_with?('/') ? css : ('/' + css))]

      cleanup_config
      @temp_file = Tempfile.new('uncssrc')
      @temp_file.write(options.to_json)
      @temp_file.flush
    end

    def cleanup_config
      return if @temp_file.nil?

      @temp_file.close
      @temp_file.unlink
    end
  end
end
