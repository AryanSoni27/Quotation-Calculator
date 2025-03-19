const Map<String, List<String>> countryCodeToIso = {
  '+93': ['AF'], // Afghanistan
  '+355': ['AL'], // Albania
  '+213': ['DZ'], // Algeria
  '+376': ['AD'], // Andorra
  '+244': ['AO'], // Angola
  '+54': ['AR'], // Argentina
  '+374': ['AM'], // Armenia
  '+61': ['AU'], // Australia
  '+43': ['AT'], // Austria
  '+994': ['AZ'], // Azerbaijan
  '+973': ['BH'], // Bahrain
  '+880': ['BD'], // Bangladesh
  '+375': ['BY'], // Belarus
  '+32': ['BE'], // Belgium
  '+501': ['BZ'], // Belize
  '+229': ['BJ'], // Benin
  '+975': ['BT'], // Bhutan
  '+591': ['BO'], // Bolivia
  '+387': ['BA'], // Bosnia and Herzegovina
  '+267': ['BW'], // Botswana
  '+55': ['BR'], // Brazil
  '+673': ['BN'], // Brunei
  '+359': ['BG'], // Bulgaria
  '+226': ['BF'], // Burkina Faso
  '+257': ['BI'], // Burundi
  '+855': ['KH'], // Cambodia
  '+237': ['CM'], // Cameroon
  '+1': ['US'], // Canada, United States
  '+236': ['CF'], // Central African Republic
  '+235': ['TD'], // Chad
  '+56': ['CL'], // Chile
  '+86': ['CN'], // China
  '+57': ['CO'], // Colombia
  '+269': ['KM'], // Comoros
  '+243': ['CD'], // Congo (DRC)
  '+242': ['CG'], // Congo (Republic)
  '+506': ['CR'], // Costa Rica
  '+225': ['CI'], // Côte d'Ivoire
  '+385': ['HR'], // Croatia
  '+53': ['CU'], // Cuba
  '+357': ['CY'], // Cyprus
  '+420': ['CZ'], // Czech Republic
  '+45': ['DK'], // Denmark
  '+253': ['DJ'], // Djibouti
  '+593': ['EC'], // Ecuador
  '+20': ['EG'], // Egypt
  '+503': ['SV'], // El Salvador
  '+240': ['GQ'], // Equatorial Guinea
  '+291': ['ER'], // Eritrea
  '+372': ['EE'], // Estonia
  '+251': ['ET'], // Ethiopia
  '+679': ['FJ'], // Fiji
  '+358': ['FI'], // Finland
  '+33': ['FR'], // France
  '+995': ['GE'], // Georgia
  '+49': ['DE'], // Germany
  '+233': ['GH'], // Ghana
  '+30': ['GR'], // Greece
  '+502': ['GT'], // Guatemala
  '+224': ['GN'], // Guinea
  '+245': ['GW'], // Guinea-Bissau
  '+592': ['GY'], // Guyana
  '+509': ['HT'], // Haiti
  '+504': ['HN'], // Honduras
  '+36': ['HU'], // Hungary
  '+354': ['IS'], // Iceland
  '+91': ['IN'], // India
  '+62': ['ID'], // Indonesia
  '+98': ['IR'], // Iran
  '+964': ['IQ'], // Iraq
  '+353': ['IE'], // Ireland
  '+972': ['IL'], // Israel
  '+39': ['IT'], // Italy
  '+81': ['JP'], // Japan
  '+962': ['JO'], // Jordan
  '+7': ['RU', 'KZ'], // Russia, Kazakhstan
  '+254': ['KE'], // Kenya
  '+82': ['KR'], // South Korea
  '+965': ['KW'], // Kuwait
  '+996': ['KG'], // Kyrgyzstan
  '+856': ['LA'], // Laos
  '+371': ['LV'], // Latvia
  '+961': ['LB'], // Lebanon
  '+231': ['LR'], // Liberia
  '+218': ['LY'], // Libya
  '+423': ['LI'], // Liechtenstein
  '+370': ['LT'], // Lithuania
  '+352': ['LU'], // Luxembourg
  '+389': ['MK'], // North Macedonia
  '+261': ['MG'], // Madagascar
  '+265': ['MW'], // Malawi
  '+60': ['MY'], // Malaysia
  '+960': ['MV'], // Maldives
  '+223': ['ML'], // Mali
  '+356': ['MT'], // Malta
  '+222': ['MR'], // Mauritania
  '+230': ['MU'], // Mauritius
  '+52': ['MX'], // Mexico
  '+373': ['MD'], // Moldova
  '+377': ['MC'], // Monaco
  '+976': ['MN'], // Mongolia
  '+382': ['ME'], // Montenegro
  '+212': ['MA'], // Morocco
  '+258': ['MZ'], // Mozambique
  '+95': ['MM'], // Myanmar
  '+264': ['NA'], // Namibia
  '+977': ['NP'], // Nepal
  '+31': ['NL'], // Netherlands
  '+64': ['NZ'], // New Zealand
  '+505': ['NI'], // Nicaragua
  '+234': ['NG'], // Nigeria
  '+47': ['NO'], // Norway
  '+968': ['OM'], // Oman
  '+92': ['PK'], // Pakistan
  '+507': ['PA'], // Panama
  '+595': ['PY'], // Paraguay
  '+51': ['PE'], // Peru
  '+63': ['PH'], // Philippines
  '+48': ['PL'], // Poland
  '+351': ['PT'], // Portugal
  '+974': ['QA'], // Qatar
  '+40': ['RO'], // Romania
  '+250': ['RW'], // Rwanda
  '+966': ['SA'], // Saudi Arabia
  '+221': ['SN'], // Senegal
  '+381': ['RS'], // Serbia
  '+65': ['SG'], // Singapore
  '+421': ['SK'], // Slovakia
  '+386': ['SI'], // Slovenia
  '+27': ['ZA'], // South Africa
  '+34': ['ES'], // Spain
  '+94': ['LK'], // Sri Lanka
  '+249': ['SD'], // Sudan
  '+46': ['SE'], // Sweden
  '+41': ['CH'], // Switzerland
  '+963': ['SY'], // Syria
  '+886': ['TW'], // Taiwan
  '+255': ['TZ'], // Tanzania
  '+66': ['TH'], // Thailand
  '+228': ['TG'], // Togo
  '+216': ['TN'], // Tunisia
  '+90': ['TR'], // Turkey
  '+993': ['TM'], // Turkmenistan
  '+256': ['UG'], // Uganda
  '+380': ['UA'], // Ukraine
  '+971': ['AE'], // United Arab Emirates
  '+44': ['GB'], // United Kingdom
  '+598': ['UY'], // Uruguay
  '+998': ['UZ'], // Uzbekistan
  '+58': ['VE'], // Venezuela
  '+84': ['VN'], // Vietnam
  '+967': ['YE'], // Yemen
  '+260': ['ZM'], // Zambia
  '+263': ['ZW']  // Zimbabwe
};