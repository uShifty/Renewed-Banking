lib.locale()
Config = {
    framework = 'qb', -- qb or esx 
    progressbar = 'circle', -- circle or rectangle (Anything other than circle will default to rectangle)
    currency ='USD', -- USD, EUR, GBP ect..... Some will work some wont...
    purgeTransactions = false, -- Deleted old transactions greater than 6 months
    atms = {
        `prop_atm_01`,
        `prop_atm_02`,
        `prop_atm_03`,
        `prop_fleeca_atm`
    },
    peds = {
        [1] = { -- Pacific Standard
            model = 'u_m_m_bankman',
            coords = vector4(241.44, 227.19, 106.29, 170.43),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [2] = {
            model = 'ig_barry',
            coords = vector4(313.84, -280.58, 54.16, 338.31),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [3] = {
            model = 'ig_barry',
            coords = vector4(149.46, -1042.09, 29.37, 335.43),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [4] = {
            model = 'ig_barry',
            coords = vector4(-351.23, -51.28, 49.04, 341.73),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [5] = {
            model = 'ig_barry',
            coords = vector4(-1211.9, -331.9, 37.78, 20.07),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [6] = {
            model = 'ig_barry',
            coords = vector4(-2961.14, 483.09, 15.7, 83.84),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [7] = {
            model = 'ig_barry',
            coords = vector4(1174.8, 2708.2, 38.09, 178.52),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        },
        [8] = { -- paleto
            model = 'u_m_m_bankman',
            coords = vector4(-112.22, 6471.01, 31.63, 134.18),
            scenario = 'PROP_HUMAN_STAND_IMPATIENT'
        }
    }
}
