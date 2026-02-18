return {
    GameId = 6808056680,
    -- Set to true when Ilum place is ready; until then only Coruscant Quick Play works
    IlumEnabled = true,
    -- Set to false to disable top bar hiding (use if top bar hide blocks clicks)
    HideTopBarInHub = false,
    -- Hub can have multiple PlaceIds (e.g. Studio vs published)
    HubPlaceIds = { 6808056680, 98619119037493 },
    PlaceIds = {
        Hub = 6808056680,
        Coruscant = 94260201585792, -- PlaceID 94260201585792, GameId 6808056680
        Ilum = 81500806921573,
    },
    PlaceDisplayNames = {
        [6808056680] = "GALACTIC HUB",
        [94260201585792] = "JEDI TEMPLE ON CORUSCANT",
        [81500806921573] = "CAVE ON ILUM",
    },
}
