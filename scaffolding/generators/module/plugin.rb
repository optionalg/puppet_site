path "modules/#{name}"

manifest do
    directory "manifests"
    template "manifests/init.pp"
end
