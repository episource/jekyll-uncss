require 'stringio'
require 'tempfile'
require 'json'

module UncssWrapper

    class Error < StandardError; end

    # Run uncss with the given config. See description of uncss's --uncssrc option.
    #   +uncssrc+ the configuration to be used as hash. Will be serialized to json and then passed to uncss using its
    #             --uncssrc option. See github.com/giakki/uncss for details.
    #   +files+   one or more html files/pages to be analyzed. Globs can be used. See github.com/isaacs/node-glob for
    #             details.
    #
    # Returns uncss output, that is css code that is actually being used by the pages that were analyzed.
    def self.uncss(uncssrc, files)
        files = [ files ].flatten

        tempfileUncssrc = Tempfile.new('uncssrc')
        tempfileUncssrc.write(uncssrc.to_json)
        tempfileUncssrc.flush

        begin
            result = `uncss --uncssrc '#{tempfileUncssrc.path}' '#{files.join("' '")}' 2>&1`
        rescue Exception => e
            raise Error, "uncss failed: #{e} :: #{result}"
        ensure
            tempfileUncssrc.close!
        end

        yield(StringIO.new(result)) if block_given?
        result
    end
end
