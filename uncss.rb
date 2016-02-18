require 'sass' # note: sass is always available as jekyll depends on it

# postprocess already rendered site
Jekyll::Hooks.register(:site, :post_write) do |site|
    config = site.config['uncss'] || {}
    if !config.key?('stylesheets')
        raise "Missing option 'uncss.stylesheets'!"
    end

    files = config.fetch('files', ['**/*.html']).collect {|x| File.join(site.dest, x)}

    config['stylesheets'].each {|s|
        uncssrc = {
            :htmlroot => site.dest,

            # uncss treats absolute stylesheet paths as relative to htmlroot
            :stylesheets => [ File.join('/', s) ],

            # these are optional and will be dropped if nil
            :ignore => config['ignore'],
            :media => config['media'],
            :timeout => config['timeout']
        }.delete_if {|k,v| v == nil}

        essentialCss = UncssWrapper::uncss(uncssrc, files)

        if config['compress']
            essentialCss = Sass.compile(essentialCss, { :style => :compressed })
        end

        File.open(File.join(site.dest, s), 'w') do |f|
            f.write(essentialCss)
        end
    }
end