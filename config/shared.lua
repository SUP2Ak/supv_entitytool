Config.SelectedLanguage = 'fr'
Config.Framework = nil -- 'ESX' or 'QB' (but you need edit for qb-core because i don't use this shit) nil = standalone and work with add_ace permission, but ESX use add_ace permission too so you can it on nil because work per default with esx

Config.Access = {
    group = {
        ['admin'] = true,
        ['modo'] = true
    }
}

Config.Languages = {

    ['fr'] = {


    },

    ['en'] = {

    }
}

tr = Config.Languages[Config.SelectedLanguage]