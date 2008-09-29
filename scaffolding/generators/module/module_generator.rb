generate :module do
    path "modules/#{name}"

    manifest do
        directory "modules/manifests"
        template "modules/README"
        template "modules/manifests/site.pp"
    end
end
