module Merb::Template

  class Liquid
    
    def self.templates; @@templates; end

    # Defines a method for calling a specific liquid template.
    #
    # ==== Parameters
    # path<String>:: Path to the template file.
    # name<~to_s>:: The name of the template method.
    # mod<Class, Module>::
    #   The class or module wherein this method should be defined.
    def self.compile_template(io, name, mod)
      path = File.expand_path(io.path)
      config = (Merb::Plugins.config[:liquid] || {}).inject({}) do |c, (k, v)|
        c[k.to_sym] = v
        c
      end.merge :filename => path
      
      Merb.logger.debug("Compiling template #{io.path}")
      
      @@templates ||= Hash.new
      template = ::Liquid::Template.parse(io.read)
      template.def_method(mod, name, path)
      @@templates[name] = template

      name
    end
  
    module Mixin
    end

    ::Liquid::Template.module_eval("alias render2 render")
    Merb::Template.register_extensions(self, %w[liquid])
  end
end

module Liquid
  class Template

    # ==== Parameters
    # object<Class, Module>::
    #   The class or module wherein this method should be defined.
    # name<~to_s>:: The name of the template method.
    # *local_names:: Local names to define in the liquid template.
    def def_method(object, name, path)
      method = object.is_a?(Module) ? :module_eval : :instance_eval

      setup = "@_engine = 'liquid'"
      runner = <<-EOF
        data = Hash.new
        instance_variables.each { |var| data[var[1..-1]] = instance_variable_get(var) }
        Merb::Template::Liquid.templates['#{name}'].render(data)
EOF

      object.send(method, "def #{name}(_liquid_locals = {}); #{setup}; #{runner}; end", __FILE__, 0)
    end
 
  end
end
