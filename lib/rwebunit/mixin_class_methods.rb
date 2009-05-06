class Module
 private

 module MixinClassMethods
   def included_by_module(klass)
     #check to see if klass is already set up
     if not klass.instance_variables.include? '@class_method_module'
       klass.send(:mixin_class_methods)
     end
     klass_method_module =
       klass.instance_variable_get('@class_method_module')
     klass_method_module.send(:include, @class_method_module)
   end

   def included(klass)
     @extra_include_block.call(klass) if @extra_include_block
     case klass
       when Class
         klass.extend(@class_method_module)
       when Module
         #more work to include in a module
         included_by_module(klass)
     end
   end

   def define_class_methods(&block)
     @class_method_module.module_eval &block
   end

 end

 def mixin_class_methods(&block)
   #ensure the existence of the ClassMethods module
   if not (Module === (@class_method_module ||= Module.new))
     fail "@class_method_module is not a module!"
   end
   @extra_include_block = block
   extend MixinClassMethods
 end

end