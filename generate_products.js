const fs = require('fs');

// All brands organized by category
const brands = {
  mode: ['Zara', 'H&M', 'Mango', 'Stradivarius', 'Bershka', 'Pull & Bear', 'Massimo Dutti', 'Uniqlo', 'COS', 'Arket', 'Weekday', '& Other Stories', 'Sézane', 'Sandro', 'Maje', 'Claudie Pierlot', 'ba&sh', 'The Kooples', 'A.P.C.', 'AMI Paris', 'Isabel Marant', 'Jacquemus', 'Reformation', 'Ganni', 'Totême', 'Anine Bing', 'The Frankie Shop', 'Promod'],
  luxe: ['Acne Studios', 'Lemaire', 'Maison Margiela', 'Saint Laurent', 'Louis Vuitton', 'Dior', 'Chanel', 'Gucci', 'Prada', 'Miu Miu', 'Fendi', 'Celine', 'Balenciaga', 'Loewe', 'Valentino', 'Givenchy', 'Burberry', 'Alexander McQueen', 'Versace', 'Balmain', 'Bottega Veneta', 'Hermès', 'Tom Ford', 'Golden Goose'],
  streetwear: ['Off-White', 'Palm Angels', 'Fear of God', 'Rhude', 'Aime Leon Dore', 'Stone Island', 'Carhartt WIP', 'Stüssy', 'Kith', 'Supreme'],
  outdoor: ['Moncler', 'Canada Goose', "Arc'teryx", 'The North Face', 'Patagonia', 'Fusalp', 'Rossignol'],
  sport: ['On Running', 'HOKA', 'Lululemon', 'Alo Yoga', 'Gymshark', 'Nike', 'Adidas', 'Jordan', 'New Balance', 'Puma', 'Asics', 'Salomon', 'Veja', 'Autry', 'Common Projects', 'Converse', 'Vans', 'Decathlon', 'Foot Locker'],
  chaussures: ['Eram', 'Jonak', 'Minelli', 'Dr. Martens', 'Paraboot', 'J.M. Weston', "Tod's", "Church's", 'Santoni', 'Hogan', 'Gianvito Rossi', 'Amina Muaddi', 'Aquazzura', 'Roger Vivier', 'By Far'],
  maison: ['IKEA', 'Maisons du Monde', 'H&M Home', 'Zara Home', 'Habitat', 'Made.com', 'Vitra', 'Hay', 'Muuto', 'Ferm Living', 'Kartell', 'Tom Dixon', 'Alessi'],
  electromenager: ['Dyson', 'SMEG', 'KitchenAid', 'Nespresso', "De'Longhi", 'Moccamaster', 'Le Creuset', 'Staub'],
  lunettes: ['Ray-Ban', 'Persol', 'Oliver Peoples', 'Warby Parker', 'Cutler and Gross'],
  bagages: ['Polène', 'Lancel', 'Longchamp', 'Cuyana', 'Coach', 'MCM', 'Rimowa', 'Tumi', 'Away', 'Samsonite'],
  tech: ['Apple', 'Samsung', 'Google Pixel', 'Bose', 'Sony', 'JBL', 'Marshall', 'Bang & Olufsen', 'Sennheiser', 'Devialet', 'Nothing', 'GoPro', 'DJI', 'Withings', 'Garmin', 'Kindle'],
  gaming: ['PlayStation', 'Xbox', 'Nintendo', 'Logitech G', 'Razer', 'SteelSeries', 'Secretlab'],
  bijoux: ['Pandora', 'Swarovski', 'Tiffany & Co.', 'Cartier', 'Van Cleef & Arpels', 'Bulgari', 'Messika', 'Dinh Van'],
  parfums: ['Le Labo', 'Byredo', 'Diptyque', 'Maison Francis Kurkdjian', 'Kilian Paris', 'Creed', 'Parfums de Marly', 'Jo Malone London', 'Aesop', 'Cire Trudon', 'Acqua di Parma'],
  beaute: ['Dior Beauty', 'Chanel Beauty', 'YSL Beauty', 'Lancôme', 'Estée Lauder', 'La Mer', 'Charlotte Tilbury', 'NARS', 'Pat McGrath Labs', 'Fenty Beauty', 'Rare Beauty', 'Tatcha', 'Drunk Elephant', 'Sephora', "Kiehl's", 'The Ordinary', 'Glossier', 'Rituals', "L'Occitane", 'Lush'],
  chocolat: ['Pierre Hermé', 'Ladurée', 'Fauchon', 'Pierre Marcolini', 'Godiva', 'Kusmi Tea', 'Mariage Frères']
};

// Product templates by category
const productTemplates = {
  mode: [
    {names: ['Wool Cashmere Coat', 'Silk Blouse', 'Tailored Blazer', 'Leather Jacket', 'Cashmere Sweater', 'Pleated Midi Skirt', 'Wide Leg Trousers', 'Knit Cardigan', 'Satin Dress', 'Velvet Blazer'], prices: [89, 299]},
    {names: ['Oversized Scarf', 'Leather Belt', 'Silk Scarf', 'Cashmere Gloves', 'Wool Beanie'], prices: [29, 99]}
  ],
  luxe: [
    {names: ['Leather Handbag', 'Designer Sunglasses', 'Silk Scarf', 'Leather Wallet', 'Cashmere Scarf', 'Logo Belt', 'Card Holder', 'Key Ring', 'Phone Case'], prices: [350, 2500]},
    {names: ['Sneakers', 'Loafers', 'Ankle Boots', 'Heeled Sandals'], prices: [450, 1200]}
  ],
  streetwear: [
    {names: ['Hoodie', 'Graphic Tee', 'Track Pants', 'Bomber Jacket', 'Baseball Cap', 'Beanie', 'Crossbody Bag'], prices: [85, 450]}
  ],
  outdoor: [
    {names: ['Down Jacket', 'Puffer Coat', 'Fleece Jacket', 'Rain Shell', 'Insulated Vest', 'Winter Boots'], prices: [250, 1200]}
  ],
  sport: [
    {names: ['Running Shoes', 'Training Sneakers', 'Yoga Mat', 'Gym Bag', 'Sports Bra', 'Leggings', 'Running Shorts', 'Track Jacket', 'Water Bottle'], prices: [45, 200]}
  ],
  chaussures: [
    {names: ['Leather Ankle Boots', 'Heeled Pumps', 'Derby Shoes', 'Loafers', 'Chelsea Boots', 'Platform Sandals', 'Sneakers', 'Ballet Flats'], prices: [120, 650]}
  ],
  maison: [
    {names: ['Table Lamp', 'Throw Pillow Set', 'Wool Rug', 'Ceramic Vase', 'Picture Frame', 'Candle Holder', 'Decorative Bowl', 'Wall Mirror', 'Coffee Table', 'Armchair', 'Bookshelf', 'Dining Chair'], prices: [25, 599]}
  ],
  electromenager: [
    {names: ['Coffee Machine', 'Vacuum Cleaner', 'Hair Dryer', 'Stand Mixer', 'Blender', 'Toaster', 'Kettle', 'Dutch Oven', 'Cookware Set'], prices: [149, 699]}
  ],
  lunettes: [
    {names: ['Aviator Sunglasses', 'Wayfarer Frames', 'Round Sunglasses', 'Cat Eye Glasses', 'Sport Sunglasses'], prices: [150, 450]}
  ],
  bagages: [
    {names: ['Cabin Suitcase', 'Leather Tote Bag', 'Crossbody Bag', 'Backpack', 'Duffle Bag', 'Travel Wallet', 'Weekender Bag'], prices: [180, 850]}
  ],
  tech: [
    {names: ['Wireless Headphones', 'Smart Speaker', 'Fitness Tracker', 'Wireless Earbuds', 'Portable Charger', 'Smartwatch', 'E-Reader', 'Drone', 'Action Camera', 'Bluetooth Speaker'], prices: [99, 599]}
  ],
  gaming: [
    {names: ['Gaming Headset', 'Mechanical Keyboard', 'Gaming Mouse', 'Gaming Chair', 'Controller', 'Console', 'VR Headset'], prices: [59, 549]}
  ],
  bijoux: [
    {names: ['Silver Necklace', 'Gold Bracelet', 'Diamond Earrings', 'Pearl Ring', 'Charm Bracelet', 'Pendant Necklace', 'Stud Earrings'], prices: [95, 2500]}
  ],
  parfums: [
    {names: ['Eau de Parfum 100ml', 'Eau de Toilette 50ml', 'Discovery Set', 'Scented Candle', 'Body Lotion', 'Travel Spray'], prices: [85, 350]}
  ],
  beaute: [
    {names: ['Lipstick', 'Foundation', 'Eyeshadow Palette', 'Mascara', 'Face Serum', 'Night Cream', 'Moisturizer', 'Cleanser', 'Face Mask Set', 'Makeup Brush Set'], prices: [24, 195]}
  ],
  chocolat: [
    {names: ['Chocolate Gift Box', 'Macaron Box', 'Tea Gift Set', 'Truffle Selection', 'Gourmet Hamper', 'Praline Box'], prices: [35, 120]}
  ]
};

const colors = ['Black', 'White', 'Navy', 'Beige', 'Brown', 'Grey', 'Cream', 'Camel', 'Burgundy', 'Olive'];
const sizes = ['XS', 'S', 'M', 'L', 'XL', 'One Size'];

function randomItem(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomPrice(min, max) {
  return (Math.random() * (max - min) + min).toFixed(2);
}

function randomRating() {
  return (Math.random() * (5.0 - 3.5) + 3.5).toFixed(1);
}

function randomReviews() {
  return Math.floor(Math.random() * 50000) + 50;
}

function generateProduct(brand, category) {
  const templates = productTemplates[category];
  if (!templates || templates.length === 0) return null;

  const template = randomItem(templates);
  const productName = randomItem(template.names);
  const price = randomPrice(template.prices[0], template.prices[1]);
  const hasDiscount = Math.random() > 0.7;
  const originalPrice = hasDiscount ? (parseFloat(price) * 1.2).toFixed(2) : "";

  // Add color/size variation for fashion items
  let title = productName;
  if (['mode', 'luxe', 'streetwear', 'chaussures'].includes(category)) {
    if (Math.random() > 0.5) {
      title += ` - ${randomItem(colors)}`;
    }
  }

  return {
    product_title: `${brand} ${title}`,
    product_price: price,
    product_original_price: originalPrice,
    product_star_rating: randomRating(),
    product_num_ratings: randomReviews(),
    product_url: `https://www.${brand.toLowerCase().replace(/\s+/g, '-').replace(/'/g, '')}.com/product/${Math.random().toString(36).substring(7)}`,
    product_photo: `https://cdn.${brand.toLowerCase().replace(/\s+/g, '-').replace(/'/g, '')}.com/images/product-${Math.random().toString(36).substring(7)}.jpg`,
    platform: brand
  };
}

// Generate products
const products = [];
const targetCount = 2500;

// Calculate products per brand
let allBrands = [];
Object.entries(brands).forEach(([category, brandList]) => {
  brandList.forEach(brand => {
    allBrands.push({brand, category});
  });
});

const productsPerBrand = Math.ceil(targetCount / allBrands.length);

allBrands.forEach(({brand, category}) => {
  for (let i = 0; i < productsPerBrand; i++) {
    const product = generateProduct(brand, category);
    if (product) {
      products.push(product);
    }
  }
});

// Shuffle products
for (let i = products.length - 1; i > 0; i--) {
  const j = Math.floor(Math.random() * (i + 1));
  [products[i], products[j]] = [products[j], products[i]];
}

// Trim to exact target
const finalProducts = products.slice(0, targetCount);

// Write to file
const output = {
  products: finalProducts
};

fs.writeFileSync('products_all_brands.json', JSON.stringify(output, null, 2));
console.log(`✅ Generated ${finalProducts.length} products from ${allBrands.length} brands!`);
