def windows?(context)
  context.respond_to?(:windows) && context.windows
end
