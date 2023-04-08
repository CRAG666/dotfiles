--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  websites to allow javascript & images

--  :lua settings .on['twitter.com'] .webview .auto_load_images = true

--  Add image-loading ability to a site while actively browsing, then reload.
--  Include address within this  com_allowed  list to make changes permanent.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local settings  = require( 'settings' )

--  domain lists divided into smaller segments to make location & insertion easier.
--  no need for  www  but other prefixes are required.  so individual github sux...
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  websites that have less-used top-level-domain names.  grouped together here.
--  may put in their own separate list(s), if enough items accrue.

local misc  = {  '127.0.0.1',  '192.168.1.1',  '192.168.1.2',  '1337x.to',
  'google.it',  'hackaday.io',  'imageshack.us',  'mega.nz',  'primewire.li',
  'shop.signaturesolar.us',  'signaturesolar.us',  'twitch.tv',
  'www1.watch-series.la',  'youtu.be',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local com  = {}

com .num_e  = {  'about',  'adobe',  'advertiser-tribune',  'akamai',
  'akamaitechnologies',  'alibaba',  'aliexpress',  'amazon',  'android',
  'atarimania',    'bbc',  'berkeyfilters',  'bhphotovideo',  'bing',
  'blogger',  'bloomberg',  'businessinsider',  'buzzfeed',  'buytwowayradios',
  'cbsnews',  'cdn.shopify',  'chaturbate',  'cloudflare',  'codeproject',
  'cnet',  'cnn',  'edition.cnn',  'dailymotion',  'dell',  'devil-forge',
  'digg',  'discord',  'disqus',  'duckduckgo',  'ebay',  'engadget',  }


com .f_q  = {  'facebook',  'forbes',  'gizmodo',  'github',  'gmail',
  'google',  'googletagmanager',  'gravatar',  'gstatic',  'homedepot',
  'huffingtonpost',  'huffpost',  'ign',  'imdb',  'imgur',  'instagram',
  'instructables',  'invertersrus',  'istockphoto',  'kickstarter',
  'laylasleep',  'lowes',  'mediafire',  'nbcnews',  'netflix',  'newegg',
  'newsweek',  'nypost',  'okchem',  'osnpower',  'overstock',  'paypal',
  'pcworld',  'pinterest',  'pixabay',  'plastic-mart'  }


com .r_z  = {  'reddit',  'redgifs',  'renogy',  'reuters',  'rt',  'santansolar',
  'sciplus',  'secondnexus',  'shutterstock',  'soundcloud',  'spotify',  'stackoverflow',
  'techcrunch',  'images.techhive',  'theguardian',  'tic80',  'time',  'tripadvisor',
  'twitter',  'mobile.twitter',  'urbandictionary',  'usedfromus',  'usnews',
  'verisign',  'vidtod',  'vidtodo',  'vimeo',  'walmart',  'washingtonpost',
  'webmd',  'wikia',  'wikihow',  'watchepisodes4',  'wikihow', 'wired',  'wp',
  'wsj',  'yahoo',  'mail.yahoo',  'youtube',  'm.youtube',  'ytimg',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  en.wikipedia.org/wiki/List_of_the_oldest_currently_registered_Internet_domain_names

local edu  = {  'albany',  'arizona',  'berkley',  'bgsu',  'brown',  'bsu',
  'bu',  'byu',  'caltech',  'carlton',  'clarkson',  'clemson',  'cmu',
  'colorado',  'columbia',  'cornell',  'csuchico',  'csufresno',  'dartmouth',
  'depaul',  'duke',  'emory',  'gatech',  'georgetown',  'harvard',  'hawaii',
  'indiana',  'isi',  'jhu',  'kent',  'lsu',  'merit',  'mit',  'moravian',
  'mu',  'muskingum',  'northeastern',  'nyu',  'oberlin',  'odu',  'ohiou',
  'okstate',  'perdue',  'princeton',  'psu',  'rice',  'rochester',  'rockefeller',
  'rpi',  'rutgers',  'sju',  'stanford',  'syr',  'toronto',  'tulane',  'uab',
  'ucdavis',  'ucf',  'uci',  'ucla',  'ucsc',  'ucsd',  'ucsf',  'udel',  'ufl',
  'uiuc',  'umass',  'umd',  'umich',  'umn',  'unc',  'unh',  'unlv',  'unm',
  'unr',  'unt',  'upenn',  'usc',  'usd',  'usf',  'usl',  'usma',  'uta',
  'utah',  'utexas',  'uvm',  'uwp',  'virginia',  'washington',  'wcslc',
  'wellesley',  'wfu',  'whoi',  'williams',  'wisc',  'wku',  'wright',
  'wsu',  'wwu',  'yale',  'yu',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local net  = {  'akamaihd',  'cloudfront ',  'go.tiffinohio',  's3.amazonaws',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local org  = {  'apache',  'archive',  'change',  'creativecommons',  'debian',
  'fltk',  'gnu',  'love2d',  'mozilla',  'npr',  'pbs',  'wikimedia',  'en.wikimedia',
  'wikipedia',  'en.wikipedia',  'wordpress',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local couk  = {  'bbc',  'dailymail',  'express',  'google',  'guardian',
  'mirror',  'telegraph',  'thesun',  }

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function allow( domain_list, domain )
    local domain  = domain or ''
    for index = 1, #domain_list do  --  what thou wilt
        local website = domain_list[ index ]

        settings .on[ website ..domain ] .webview .auto_load_images  = true
        settings .on[ website ..domain ] .webview .javascript_can_open_windows_automatically  = true
    end
end


for alpha, contents in pairs( com ) do
    allow( contents, '.com' )
end

allow( misc )  --  do not append TLD's for these

allow( edu, '.edu' )
allow( org, '.org' )
allow( net, '.net' )
allow( couk, '.co.uk' )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  Not ideal cantidates for scripts, because they may jump you to unexpected sites:
--
--  'bit.ly',  'tinyurl.com',  'goog.le'    You may need them, but leaving them out, 
--  then just turning them on occasionally thwarts rick-roll attempts.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
