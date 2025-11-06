/// Liste complète des marques pour la génération de cadeaux
class BrandList {
  static const String brands = '''
Zara, Zara Men, Zara Women, Zara Home, H&M, Mango, Stradivarius, Bershka, Pull & Bear, Massimo Dutti, Uniqlo, COS, Arket, Weekday, & Other Stories, Sézane, Sandro, Maje, Claudie Pierlot, ba&sh, The Kooples, A.P.C., AMI Paris, Isabel Marant, Jacquemus, Reformation, Ganni, Totême, Anine Bing, The Frankie Shop, Acne Studios, Lemaire, Officine Générale, Maison Margiela, Saint Laurent, Louis Vuitton, Dior, Chanel, Gucci, Prada, Miu Miu, Fendi, Celine, Balenciaga, Loewe, Valentino, Givenchy, Burberry, Alexander McQueen, Versace, Balmain, Bottega Veneta, Hermès, Alaïa, JW Anderson, Rick Owens, Tom Ford, Golden Goose, Off-White, Palm Angels, Fear of God, Rhude, Aime Leon Dore, Stone Island, C.P. Company, Carhartt WIP, Stüssy, Kith, Supreme, Moncler, Canada Goose, Arc'teryx, The North Face, Patagonia, Fusalp, Rossignol, On Running, HOKA, Lululemon, Alo Yoga, Gymshark, Nike, Adidas, Jordan, New Balance, Puma, Asics, Salomon, Veja, Autry, Common Projects, Axel Arigato, Converse, Vans, Maison Kitsuné, Balibaris, Le Slip Français, Faguo, American Vintage, Soeur, Sessùn, Maison Labiche, De Bonne Facture, Le Bon Marché, Galeries Lafayette, Printemps, La Redoute, La Samaritaine, Selfridges, Harrods, El Corte Inglés, IKEA, Maisons du Monde, H&M Home, Habitat, Alinéa, Made.com, Vitra, Hay, Muuto, Ferm Living, Kartell, Tom Dixon, Alessi, Flos, Artemide, Dyson, SMEG, KitchenAid, Nespresso, De'Longhi, Moccamaster, Le Creuset, Staub, Riedel, Le Petit Lunetier, Ray-Ban, Persol, Oliver Peoples, Warby Parker, Cutler and Gross, Linda Farrow, Polène, Lancel, Longchamp, Cuyana, Coach, MCM, Rimowa, Tumi, Away, Samsonite, Delsey, Briggs & Riley, Montblanc, Bellroy, Nomad Goods, Peak Design, Native Union, Mujjo, Apple, Samsung, Google Pixel, Dyson Tech, Bose, Sony, JBL, Marshall, Bang & Olufsen, Bowers & Wilkins, Sennheiser, Devialet, Nothing, GoPro, DJI, Withings, Garmin, Kindle, PlayStation, Xbox, Nintendo, Logitech G, Razer, SteelSeries, Secretlab, Scuf, Bell, POC, Giro, Kask, HJC, Shark, Eram, Jonak, Minelli, Bocage, Dr. Martens, Paraboot, J.M. Weston, Tod's, Church's, Santoni, Hogan, Gianvito Rossi, Amina Muaddi, Aquazzura, Roger Vivier, By Far, Pandora, Swarovski, Tiffany & Co., Cartier, Van Cleef & Arpels, Bulgari, Messika, Chaumet, Fred, Dinh Van, Repossi, Aristocrazy, Maison Cléo, Le Labo, Byredo, Diptyque, Maison Francis Kurkdjian, Kilian Paris, Creed, Parfums de Marly, BDK Parfums, DS & Durga, Jo Malone London, Aesop, Cire Trudon, Acqua di Parma, Dior Beauty, Chanel Beauty, YSL Beauty, Lancôme, Estée Lauder, La Mer, La Prairie, Guerlain, Shiseido, Charlotte Tilbury, Armani Beauty, Hourglass, NARS, Pat McGrath Labs, Fenty Beauty, Rare Beauty, Tatcha, Dr. Barbara Sturm, Augustinus Bader, SkinCeuticals, Drunk Elephant, Summer Fridays, Sephora, Marionnaud, Nocibé, LookFantastic, Cult Beauty, FeelUnique, Kiehl's, The Ordinary, Paula's Choice, Glossier, Rituals, L'Occitane, The Body Shop, Rituals Home, Zara Home Parfum, Amazon, Zalando, Asos, Farfetch, Net-A-Porter, MyTheresa, SSENSE, MatchesFashion, END Clothing, Mr Porter, Browns Fashion, StockX, GOAT, Chrono24, Back Market, Rakuten, Cdiscount, Nature & Découvertes, Fnac, Darty, Boulanger, Cultura, Apple Store, Decathlon, Go Sport, Courir, Foot Locker, JD Sports, Lush, Yves Rocher, KIKO Milano, La Maison du Chocolat, Pierre Hermé, Ladurée, Fauchon, Angelina, Pierre Marcolini, Godiva, Venchi, Patrick Roger, Maison Plisson, Kusmi Tea, Mariage Frères, Dammann Frères, Nespresso, Sephora Collection, Diptyque Bougies, Byredo Home, Cire Trudon Bougies, Vitra Home, Hay Design, Ferm Living, Muuto Design, Alessi Home, Tom Dixon Home, IKEA Premium, Maisons du Monde Cadeaux, Zara Home Déco, H&M Home Cadeaux, Smeg Electro, Dyson Hair, Dyson Purifier, Apple Watch, iPhone, iPad, AirPods, MacBook, Beats by Dre, Bose Headphones, Sony XM5, Bang & Olufsen Beoplay, Devialet Phantom, JBL Partybox, GoPro Hero 12, DJI Mini 4 Pro, Garmin Fenix, Withings Scanwatch, Kindle Paperwhite, Playstation 5, Xbox Series X, Nintendo Switch OLED, Secretlab Titan Evo, Logitech MX, Razer Blackwidow, SteelSeries Arctis, Sezane Maison, Nature & Découvertes Bien-être, Rituals Home Sets, L'Occitane Coffrets, Kusmi Tea Coffrets, Fauchon Coffrets, Ladurée Coffrets, Le Slip Français Coffrets, Polène Paris, Tumi, Rimowa, Away, Montblanc, Nomad Goods, Native Union, Bellroy, Peak Design, Muji, Monoprix Sélection Cadeaux, Printemps Luxe, Galeries Lafayette Luxe, Le Bon Marché Sélection, La Redoute Intérieurs, Promod, Kippa, Rhode, Maison Kitsuné, Apple, Bell, StockX, Tom Ford Beauty, Rhode Skin, Zara Home Parfum, IKEA Cadeaux
''';

  /// Mapping des tags vers les marques recommandées
  static const Map<String, List<String>> tagToBrands = {
    // Bien-être & Beauté
    'bien-être': ['Sephora', 'Rituals', 'L\'Occitane', 'Aesop', 'Yves Rocher', 'The Body Shop', 'Lush', 'Diptyque', 'Byredo', 'Le Labo', 'Cire Trudon'],
    'beauté': ['Sephora', 'Dior Beauty', 'Chanel Beauty', 'YSL Beauty', 'Charlotte Tilbury', 'NARS', 'Fenty Beauty', 'Rare Beauty', 'Glossier'],
    'parfum': ['Le Labo', 'Byredo', 'Diptyque', 'Maison Francis Kurkdjian', 'Kilian Paris', 'Creed', 'Jo Malone London', 'Acqua di Parma'],

    // Mode & Style
    'mode': ['Zara', 'H&M', 'Mango', 'Sézane', 'Sandro', 'Maje', 'ba&sh', 'The Kooples', 'A.P.C.', 'AMI Paris'],
    'luxe': ['Louis Vuitton', 'Dior', 'Chanel', 'Gucci', 'Prada', 'Hermès', 'Saint Laurent', 'Celine', 'Balenciaga', 'Bottega Veneta'],
    'streetwear': ['Supreme', 'Stüssy', 'Kith', 'Off-White', 'Palm Angels', 'Fear of God', 'Stone Island', 'Carhartt WIP'],
    'minimaliste': ['COS', 'Arket', 'Totême', 'Lemaire', 'A.P.C.', 'Acne Studios', 'Maison Margiela'],

    // Sport & Outdoor
    'sport': ['Nike', 'Adidas', 'Lululemon', 'Alo Yoga', 'On Running', 'HOKA', 'Gymshark', 'Decathlon', 'Salomon'],
    'running': ['Nike', 'Adidas', 'On Running', 'HOKA', 'Asics', 'New Balance', 'Salomon'],
    'yoga': ['Lululemon', 'Alo Yoga', 'Manduka', 'Beyond Yoga'],
    'outdoor': ['The North Face', 'Patagonia', 'Arc\'teryx', 'Moncler', 'Canada Goose'],

    // Tech & Gaming
    'tech': ['Apple', 'Samsung', 'Dyson', 'Bose', 'Sony', 'Bang & Olufsen', 'Withings', 'Garmin'],
    'gaming': ['PlayStation', 'Xbox', 'Nintendo', 'Logitech G', 'Razer', 'SteelSeries', 'Secretlab'],
    'audio': ['Bose', 'Sony', 'JBL', 'Marshall', 'Bang & Olufsen', 'Sennheiser', 'Devialet', 'Apple AirPods'],

    // Maison & Déco
    'maison': ['IKEA', 'Maisons du Monde', 'Zara Home', 'H&M Home', 'Habitat', 'Vitra', 'Hay', 'Muuto'],
    'déco': ['Zara Home', 'H&M Home', 'Maisons du Monde', 'Ferm Living', 'Hay', 'Kartell', 'Tom Dixon'],
    'cuisine': ['Le Creuset', 'Staub', 'KitchenAid', 'SMEG', 'Nespresso', 'Moccamaster', 'Alessi'],

    // Accessoires
    'sacs': ['Polène', 'Longchamp', 'Lancel', 'Cuyana', 'Coach', 'Louis Vuitton', 'Prada', 'Gucci'],
    'chaussures': ['Nike', 'Adidas', 'New Balance', 'Veja', 'Common Projects', 'Dr. Martens', 'Golden Goose'],
    'bijoux': ['Pandora', 'Swarovski', 'Tiffany & Co.', 'Cartier', 'Van Cleef & Arpels', 'Dinh Van', 'Messika'],

    // Gourmandise
    'chocolat': ['La Maison du Chocolat', 'Pierre Hermé', 'Ladurée', 'Fauchon', 'Pierre Marcolini', 'Godiva'],
    'thé': ['Kusmi Tea', 'Mariage Frères', 'Dammann Frères', 'Palais des Thés'],
    'café': ['Nespresso', 'Moccamaster', 'De\'Longhi', 'Café Verlet'],
  };
}
