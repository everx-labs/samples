```---
'###"(BigGuy573/samples/master-BigGuy573/blame/BigGuy573/main-JavaScript_SDK_Script_Configuration.js'80670e50524')]['JavaScript_SDK_Script_Configuration-js' push blame to-> raw
'->('link:]['raw.githubusercontent.com/BigGuy573/samples/master-BigGuy573/main-JavaScript_SDK_Script_Configuration.js/JavaScript_SDK_Script_Configuration.js)' 
pull request from blame -> to raw
->"('BigGuy573/samples/master-BigGuy573/blame/BigGuy573/main-JavaScript_SDK_Script_Configuration.js'80670e50524')]['JavaScript_SDK_Script_Configuration-js)'
--[[
	This class is instantiated for every card reader in an SCPF game. It handles interactions made to thel which are eventually transmitted to the parent door or elevator, and handles the leds on them. It has a locking system which disables interactions and locks the leds at their current state.
]]

--// Class setup
local ReaderClass = {}
ReaderClass.__index = ReaderClass

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
```---            
            PayPal Commerce Platform for Business / JavaScript SDK / JavaScript SDK Script Configuration
JavaScript SDK script configuration
SDK
CURRENT


You can customize your integration by passing query parameters and script parameters in the JavaScript SDK script tag. These parameters help PayPal decide the optimal funding sources and buttons to show to your buyers.

Query parameters
Query parameters are used to help define specific content or actions based on the data being passed. Each piece of data you send:

Is made up of a key-value pair. Keys define the piece of information needed and the value provides that information. The key is separated from the value by an equal sign (=).
Is proceeded by a question mark (?) to annotate that a question for a piece of information is being asked.
Is followed by an ampersand (&) if you need to provide more than one set at a time.
Contains necessary information that PayPal needs to handle your request.
For example, PayPal needs your authorization credentials and where you are to process your request:

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&locale=en_US"></script>

Use these test parameters to see JavaScript SDK results. Not passing one triggers use of the default value listed.

Option	Example value	Default	Description
client-id	test	n/a	Required.

Your PayPal REST client ID. This identifies your PayPal account, and determines where any transactions are paid to. While you're testing in sandbox, you can use client-id=sb as a shortcut.
buyer-country	US, CA, GB, DE, FR	automatic	The buyer country. Available in Sandbox for testing.
commit	true, false	true	Set to true if the transaction is completed on the PayPal review page or false if the amount captured changes after the buyer returns to your site. Not applicable for subscriptions.
Important: If you're integrating with a PayPal API, make sure the commit value you pass in the API call matches the value you pass in the JavaScript call.
components	buttons	buttons	A comma-separated list of components to enable. Defaults to allow checkout buttons. Other components are optional.
currency	USD, CAD, EUR	USD	The currency of the transaction or subscription plan.
debug	true, false	false	Enable debug mode for ease of debugging. Do not enable for production traffic.
disable-card	visa	none	Deprecated. Cards to disable from showing in the checkout buttons.
disable-funding	card, credit, bancontact	none	Funding sources to disallow from showing in the checkout buttons. Do not use this query parameter to disable advanced credit and debit card payments.
enable-funding	venmo, paylater	none	Funding sources to allow in the checkout buttons.
integration-date	2018-11-30	automatic	The date of integration. Used to ensure backwards compatibility.
intent	capture, authorize, subscription, tokenize	capture	Determines whether the funds are captured immediately on checkout or if the buyer authorizes the funds to be captured later.
Important: If you're integrating with a PayPal API, make sure the intent value you pass in the API call matches the value you pass in the JavaScript call.
locale	en_US, fr_FR, de_DE	automatic	The locale used to localize any components. PayPal recommends not setting this parameter, as the buyer's locale is automatically set by PayPal.
merchant-id	ABC123	automatic	The merchant for whom you are facilitating a transaction.
vault	true, false	false	Set to true if the transaction sets up a billing agreement or subscription.
Client ID
The client ID identifies the PayPal account that sets up and finalizes transactions. By default, funds from any transactions are settled into this account.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID"></script>

If you are facilitating transactions on behalf of other merchants and capturing funds into their accounts, see merchant ID.

Buyer country
The buyer country determines which funding sources are eligible for a given buyer. Defaults to the buyer's IP geolocation.

Note: Buyer country is valid only in sandbox and you should not pass it in production.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&buyer-country=DE"></script>

Any country that you can pass as a locale is a valid buyer country.

Commit
The commit status of the transaction. Determines whether to show a Pay Now or Continue button in the Checkout flow.

Use the Pay Now button when the buyer completes payment on the PayPal review page, for example, digitally-delivered items without shipping costs.
Use the Continue button when the buyer completes payment on your site to account for shipping, tax, and other items before submitting the order.
Important: If you're integrating with a PayPal API, make sure the commit value you pass in the API call matches the value you pass in the JavaScript call.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&commit=false"></script>

Option	Description
true	Default.
Show a Pay Now button in the PayPal Checkout flow. The final amount does not change after the buyer returns from PayPal to your site.
false	Show a Continue button in the PayPal Checkout flow. The final amount might change after the buyer returns from PayPal to your site, due to shipping, tax, or other fees.
Components
The PayPal components you intend to render on your page. Each component you use must be separated by a comma (,). If you don't pass any components, the default payment buttons component automatically renders all eligible buttons in a single location on your page. Components available to you:

Option	Description
buttons	Places all of the eligible checkout buttons on your page.
marks	Presents other funding sources on your page alongside PayPal using Radio Buttons.
messages	Displays messaging for the most relevant Pay Later offer for every purchase.
funding-eligibility	Allows you to choose the individual payment buttons (methods) you want to display on your web page.
hosted-fields	Shows your own hosted credit and debit card fields.
For example, you want to offer your buyers Pay Later options when they choose PayPal along with other payment options.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&components=buttons,marks,messages="></script>

Currency
The currency for the transaction. Funds are captured into your account in the specified currency. Defaults to USD.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&currency=EUR"></script>

Currency	Code
Australian dollar	AUD
Brazilian real	BRL
Canadian dollar	CAD
Czech koruna	CZK
Danish krone	DKK
Euro	EUR
Hong Kong dollar	HKD
Hungarian forint	HUF
Israeli new shekel	ILS
Japanese yen	JPY
Malaysian ringgit	MYR
Mexican peso	MXN
New Taiwan dollar	TWD
New Zealand dollar	NZD
Norwegian krone	NOK
Philippine peso	PHP
Polish złoty	PLN
Pound sterling	GBP
Russian ruble	RUB
Singapore dollar	SGD
Swedish krona	SEK
Swiss franc	CHF
Thai baht	THB
United States dollar	USD
Debug
Set to true to enable debug mode. Debug mode is recommended only for testing and debugging. This causes a significant increase in the size of the script and negative impact performance impact. Defaults to false.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&debug=true"></script>

Option	Description
true	Enable debug mode.
false	Disable debug mode.
Disable card
This parameter is deprecated. In previous versions of the JavaScript SDK that displayed individual card icons, this parameter disabled specific cards for the transaction. Any cards passed were not displayed in the checkout buttons.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&disable-card=amex,jcb"></script>

Option	Description
visa	Visa
mastercard	Mastercard
amex	American Express
discover	Discover
jcb	JCB
elo	Elo
hiper	Hiper
Disable funding
The disabled funding sources for the transaction. Any funding sources passed are not displayed in the checkout buttons. By default, funding source eligibility is determined based on a variety of factors. Do not use this query parameter to disable advanced credit and debit card payments.

Note: Pass credit in disable-funding for merchants that fall into these categories:

Real money gaming merchants
Non-US merchants who do not have the correct licenses and approvals to display the Credit button
<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&disable-funding=credit,card"></script>

Option	Description
card	Credit or debit cards
credit	PayPal Credit
bancontact	Bancontact
blik	BLIK
eps	eps
giropay	giropay
ideal	iDEAL
mercadopago	Mercado Pago
mybank	MyBank
p24	Przelewy24
sepa	SEPA-Lastschrift
sofort	Sofort
venmo	Venmo
Enable funding
The enabled funding sources for the transaction. By default, funding source eligibility is determined based on a variety of factors. Enable funding can be used to ensure a funding source is rendered, if eligible.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&enable-funding=venmo"></script>

Option	Description
card	Credit or debit cards
credit	PayPal Credit
paylater	Pay Later
venmo	Venmo
bancontact	Bancontact
blik	BLIK
eps	eps
giropay	giropay
ideal	iDEAL
mercadopago	Mercado Pago
mybank	MyBank
p24	Przelewy24
sepa	SEPA-Lastschrift
sofort	Sofort
Integration date
The integration date of the script, passed as a YYYY-MM-DD value. Defaults to the date when your client ID was created, and if passed, reflects the date that you added the PayPal integration to your site. This parameter ensures backwards compatibility.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&integration-date=2018-11-07"></script>

How this works:

Your site automatically gets any backward-compatible changes made to the PayPal script. These changes include:

New funding sources
Buttons
Updated user interfaces
Bug fixes
Security fixes
Performance optimizations
You do not need to change integration-date to enable new features.

Your site does not get any backward incompatible updates made to the PayPal script after the specified integration-date, or after the date your client-id was created, if you do not pass the integration-date parameter.

If your client-id does not change, you can safely omit the integration-date parameter and the PayPal script guarantees backward compatibility.

If your client-id changes dynamically, you must pass an integration date, which ensures that no breaking changes are made to your integration. This could be the case if you build a cart app, which enables merchants to dynamically set a client ID to add PayPal to their store.

Intent
The intent for the transaction. This determines whether the funds are captured immediately while the buyer is present on the page. Defaults to capture.

Important: If you're integrating with a PayPal API, make sure the intent value you pass in the API call matches the value you pass in the JavaScript call.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&intent=authorize"></script>

Option	Description
capture	The funds are captured immediately while the buyer is present on your site.
authorize	The funds are authorized immediately and then reauthorized or captured later.
subscription	Used along with vault=true to specify this is a subscription transaction.
tokenize	Used along with vault=true and createBillingAgreement() to specify this is a billing (without purchase) transaction.
Intent options when integrating with older APIs
If you're integrating the JavaScript SDK with an older API like the Orders V1 REST API or one of our NVP/SOAP solutions, you can use the following options.

Option	Description
capture or sale	The funds are captured immediately while the buyer is present on your site. The value you use should match the intent value in the API call.
authorize	The funds are authorized immediately and then reauthorized or captured later.
order	The funds are validated without an authorization and you can reauthorize or capture later.
Locale
The locale renders components. By default PayPal detects the correct locale for the buyer based on their geolocation and browser preferences. It is recommended to pass this parameter only if you need the PayPal buttons to render in the same language as the rest of your site.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&locale=fr_FR"></script>

Country	Country code	Locales
ALBANIA	AL	en_AL
ALGERIA	DZ	ar_DZ, en_DZ, fr_DZ, es_DZ, zh_DZ
ANDORRA	AD	en_AD, fr_AD, es_AD, zh_AD
ANGOLA	AO	en_AO, fr_AO, es_AO, zh_AO
ANGUILLA	AI	en_AI, fr_AI, es_AI, zh_AI
ANTIGUA & BARBUDA	AG	en_AG, fr_AG, es_AG, zh_AG
ARGENTINA	AR	es_AR, en_AR
ARMENIA	AM	en_AM, fr_AM, es_AM, zh_AM
ARUBA	AW	en_AW, fr_AW, es_AW, zh_AW
AUSTRALIA	AU	en_AU
AUSTRIA	AT	de_AT, en_AT
AZERBAIJAN	AZ	en_AZ, fr_AZ, es_AZ, zh_AZ
BAHAMAS	BS	en_BS, fr_BS, es_BS, zh_BS
BAHRAIN	BH	ar_BH, en_BH, fr_BH, es_BH, zh_BH
BARBADOS	BB	en_BB, fr_BB, es_BB, zh_BB
BELARUS	BY	en_BY
BELGIUM	BE	en_BE, nl_BE, fr_BE
BELIZE	BZ	en_BZ, es_BZ, fr_BZ, zh_BZ
BENIN	BJ	fr_BJ, en_BJ, es_BJ, zh_BJ
BERMUDA	BM	en_BM, fr_BM, es_BM, zh_BM
BHUTAN	BT	en_BT
BOLIVIA	BO	es_BO, en_BO, fr_BO, zh_BO
BOSNIA & HERZEGOVINA	BA	en_BA
BOTSWANA	BW	en_BW, fr_BW, es_BW, zh_BW
BRAZIL	BR	pt_BR, en_BR
BRITISH VIRGIN ISLANDS	VG	en_VG, fr_VG, es_VG, zh_VG
BRUNEI	BN	en_BN
BULGARIA	BG	en_BG
BURKINA FASO	BF	fr_BF, en_BF, es_BF, zh_BF
BURUNDI	BI	fr_BI, en_BI, es_BI, zh_BI
CAMBODIA	KH	en_KH
CAMEROON	CM	fr_CM, en_CM
CANADA	CA	en_CA, fr_CA
CAPE VERDE	CV	en_CV, fr_CV, es_CV, zh_CV
CAYMAN ISLANDS	KY	en_KY, fr_KY, es_KY, zh_KY
CHAD	TD	fr_TD, en_TD, es_TD, zh_TD
CHILE	CL	es_CL, en_CL, fr_CL, zh_CL
CHINA	CN	zh_CN
COLOMBIA	CO	es_CO, en_CO, fr_CO, zh_CO
COMOROS	KM	fr_KM, en_KM, es_KM, zh_KM
CONGO-BRAZZAVILLE	CG	en_CG, fr_CG, es_CG, zh_CG
CONGO-KINSHASA	CD	fr_CD, en_CD, es_CD, zh_CD
COOK ISLANDS	CK	en_CK, fr_CK, es_CK, zh_CK
COSTA RICA	CR	es_CR, en_CR, fr_CR, zh_CR
CÔTE D’IVOIRE	CI	fr_CI, en_CI
CROATIA	HR	en_HR
CYPRUS	CY	en_CY
CZECH REPUBLIC	CZ	cs_CZ, en_CZ, fr_CZ, es_CZ, zh_CZ
DENMARK	DK	da_DK, en_DK
DJIBOUTI	DJ	fr_DJ, en_DJ, es_DJ, zh_DJ
DOMINICA	DM	en_DM, fr_DM, es_DM, zh_DM
DOMINICAN REPUBLIC	DO	es_DO, en_DO, fr_DO, zh_DO
ECUADOR	EC	es_EC, en_EC, fr_EC, zh_EC
EGYPT	EG	ar_EG, en_EG, fr_EG, es_EG, zh_EG
EL SALVADOR	SV	es_SV, en_SV, fr_SV, zh_SV
ERITREA	ER	en_ER, fr_ER, es_ER, zh_ER
ESTONIA	EE	en_EE, ru_EE, fr_EE, es_EE, zh_EE
ETHIOPIA	ET	en_ET, fr_ET, es_ET, zh_ET
FALKLAND ISLANDS	FK	en_FK, fr_FK, es_FK, zh_FK
FAROE ISLANDS	FO	da_FO, en_FO, fr_FO, es_FO, zh_FO
FIJI	FJ	en_FJ, fr_FJ, es_FJ, zh_FJ
FINLAND	FI	fi_FI, en_FI, fr_FI, es_FI, zh_FI
FRANCE	FR	fr_FR, en_FR
FRENCH GUIANA	GF	en_GF, fr_GF, es_GF, zh_GF
FRENCH POLYNESIA	PF	en_PF, fr_PF, es_PF, zh_PF
GABON	GA	fr_GA, en_GA, es_GA, zh_GA
GAMBIA	GM	en_GM, fr_GM, es_GM, zh_GM
GEORGIA	GE	en_GE, fr_GE, es_GE, zh_GE
GERMANY	DE	de_DE, en_DE
GIBRALTAR	GI	en_GI, fr_GI, es_GI, zh_GI
GREECE	GR	el_GR, en_GR, fr_GR, es_GR, zh_GR
GREENLAND	GL	da_GL, en_GL, fr_GL, es_GL, zh_GL
GRENADA	GD	en_GD, fr_GD, es_GD, zh_GD
GUADELOUPE	GP	en_GP, fr_GP, es_GP, zh_GP
GUATEMALA	GT	es_GT, en_GT, fr_GT, zh_GT
GUINEA	GN	fr_GN, en_GN, es_GN, zh_GN
GUINEA - BISSAU	GW	en_GW, fr_GW, es_GW, zh_GW
GUYANA	GY	en_GY, fr_GY, es_GY, zh_GY
HONDURAS	HN	es_HN, en_HN, fr_HN, zh_HN
HONG KONG SAR CHINA	HK	en_HK, zh_HK
HUNGARY	HU	hu_HU, en_HU, fr_HU, es_HU, zh_HU
ICELAND	IS	en_IS
INDIA	IN	en_IN
INDONESIA	ID	id_ID, en_ID
IRELAND	IE	en_IE, fr_IE, es_IE, zh_IE
ISRAEL	IL	he_IL, en_IL
ITALY	IT	it_IT, en_IT
JAMAICA	JM	en_JM, es_JM, fr_JM, zh_JM
JAPAN	JP	ja_JP, en_JP
JORDAN	JO	ar_JO, en_JO, fr_JO, es_JO, zh_JO
KAZAKHSTAN	KZ	en_KZ, fr_KZ, es_KZ, zh_KZ
KENYA	KE	en_KE, fr_KE, es_KE, zh_KE
KIRIBATI	KI	en_KI, fr_KI, es_KI, zh_KI
KUWAIT	KW	ar_KW, en_KW, fr_KW, es_KW, zh_KW
KYRGYZSTAN	KG	en_KG, fr_KG, es_KG, zh_KG
LAOS	LA	en_LA
LATVIA	LV	en_LV, ru_LV, fr_LV, es_LV, zh_LV
LESOTHO	LS	en_LS, fr_LS, es_LS, zh_LS
LIECHTENSTEIN	LI	en_LI, fr_LI, es_LI, zh_LI
LITHUANIA	LT	en_LT, ru_LT, fr_LT, es_LT, zh_LT
LUXEMBOURG	LU	en_LU, de_LU, fr_LU, es_LU, zh_LU
MACEDONIA	MK	en_MK
MADAGASCAR	MG	en_MG, fr_MG, es_MG, zh_MG
MALAWI	MW	en_MW, fr_MW, es_MW, zh_MW
MALAYSIA	MY	en_MY
MALDIVES	MV	en_MV
MALI	ML	fr_ML, en_ML, es_ML, zh_ML
MALTA	MT	en_MT
MARSHALL ISLANDS	MH	en_MH, fr_MH, es_MH, zh_MH
MARTINIQUE	MQ	en_MQ, fr_MQ, es_MQ, zh_MQ
MAURITANIA	MR	en_MR, fr_MR, es_MR, zh_MR
MAURITIUS	MU	en_MU, fr_MU, es_MU, zh_MU
MAYOTTE	YT	en_YT, fr_YT, es_YT, zh_YT
MEXICO	MX	es_MX, en_MX
MICRONESIA	FM	en_FM
MOLDOVA	MD	en_MD
MONACO	MC	fr_MC, en_MC
MONGOLIA	MN	en_MN
MONTENEGRO	ME	en_ME
MONTSERRAT	MS	en_MS, fr_MS, es_MS, zh_MS
MOROCCO	MA	ar_MA, en_MA, fr_MA, es_MA, zh_MA
MOZAMBIQUE	MZ	en_MZ, fr_MZ, es_MZ, zh_MZ
NAMIBIA	NA	en_NA, fr_NA, es_NA, zh_NA
NAURU	NR	en_NR, fr_NR, es_NR, zh_NR
NEPAL	NP	en_NP
NETHERLANDS	NL	nl_NL, en_NL
NETHERLANDS ANTILLES	AN	en_AN, fr_AN, es_AN, zh_AN
NEW CALEDONIA	NC	en_NC, fr_NC, es_NC, zh_NC
NEW ZEALAND	NZ	en_NZ, fr_NZ, es_NZ, zh_NZ
NICARAGUA	NI	es_NI, en_NI, fr_NI, zh_NI
NIGER	NE	fr_NE, en_NE, es_NE, zh_NE
NIGERIA	NG	en_NG
NIUE	NU	en_NU, fr_NU, es_NU, zh_NU
NORFOLK ISLAND	NF	en_NF, fr_NF, es_NF, zh_NF
NORWAY	NO	no_NO, en_NO
OMAN	OM	ar_OM, en_OM, fr_OM, es_OM, zh_OM
PALAU	PW	en_PW, fr_PW, es_PW, zh_PW
PANAMA	PA	es_PA, en_PA, fr_PA, zh_PA
PAPAUA NEW GUINEA	PG	en_PG, fr_PG, es_PG, zh_PG
PARAGUAY	PY	es_PY, en_PY
PERU	PE	es_PE, en_PE, fr_PE, zh_PE
PHILIPPINES	PH	en_PH
PITCAIRN ISLANDS	PN	en_PN, fr_PN, es_PN, zh_PN
POLAND	PL	pl_PL, en_PL
PORTUGAL	PT	pt_PT, en_PT
QATAR	QA	en_QA, fr_QA, es_QA, zh_QA, ar_QA
RÉUNION	RE	en_RE, fr_RE, es_RE, zh_RE
ROMANIA	RO	en_RO, fr_RO, es_RO, zh_RO
RUSSIA	RU	ru_RU, en_RU
RWANDA	RW	fr_RW, en_RW, es_RW, zh_RW
SAMOA	WS	en_WS
SAN MARINO	SM	en_SM, fr_SM, es_SM, zh_SM
SÃO TOMÉ & PRÍNCIPE	ST	en_ST, fr_ST, es_ST, zh_ST
SAUDI ARABIA	SA	ar_SA, en_SA, fr_SA, es_SA, zh_SA
SENEGAL	SN	fr_SN, en_SN, es_SN, zh_SN
SERBIA	RS	en_RS, fr_RS, es_RS, zh_RS
SEYCHELLES	SC	fr_SC, en_SC, es_SC, zh_SC
SIERRA LEONE	SL	en_SL, fr_SL, es_SL, zh_SL
SINGAPORE	SG	en_SG
SLOVAKIA	SK	sk_SK, en_SK, fr_SK, es_SK, zh_SK
SLOVENIA	SI	en_SI, fr_SI, es_SI, zh_SI
SOLOMON ISLANDS	SB	en_SB, fr_SB, es_SB, zh_SB
SOMALIA	SO	en_SO, fr_SO, es_SO, zh_SO
SOUTH AFRICA	ZA	en_ZA, fr_ZA, es_ZA, zh_ZA
SOUTH KOREA	KR	ko_KR, en_KR
SPAIN	ES	es_ES, en_ES
SRI LANKA	LK	en_LK
ST. HELENA	SH	en_SH, fr_SH, es_SH, zh_SH
ST. KITTS & NEVIS	KN	en_KN, fr_KN, es_KN, zh_KN
ST. LUCIA	LC	en_LC, fr_LC, es_LC, zh_LC
ST. PIERRE & MIQUELON	PM	en_PM, fr_PM, es_PM, zh_PM
ST. VINCENT & GRENADINES	VC	en_VC, fr_VC, es_VC, zh_VC
SURINAME	SR	en_SR, fr_SR, es_SR, zh_SR
SVALBARD & JAN MAYEN	SJ	en_SJ, fr_SJ, es_SJ, zh_SJ
SWAZILAND	SZ	en_SZ, fr_SZ, es_SZ, zh_SZ
SWEDEN	SE	sv_SE, en_SE
SWITZERLAND	CH	de_CH, fr_CH, en_CH
TAIWAN	TW	zh_TW, en_TW
TAJIKISTAN	TJ	en_TJ, fr_TJ, es_TJ, zh_TJ
TANZANIA	TZ	en_TZ, fr_TZ, es_TZ, zh_TZ
THAILAND	TH	th_TH, en_TH
TOGO	TG	fr_TG, en_TG, es_TG, zh_TG
TONGA	TO	en_TO
TRINIDAD & TOBAGO	TT	en_TT, fr_TT, es_TT, zh_TT
TUNISIA	TN	ar_TN, en_TN, fr_TN, es_TN, zh_TN
TURKMENISTAN	TM	en_TM, fr_TM, es_TM, zh_TM
TURKS & CAICOS ISLANDS	TC	en_TC, fr_TC, es_TC, zh_TC
TUVALU	TV	en_TV, fr_TV, es_TV, zh_TV
TURKEY	TR	tr_TR, en_TR
UGANDA	UG	en_UG, fr_UG, es_UG, zh_UG
UKRAINE	UA	en_UA, ru_UA, fr_UA, es_UA, zh_UA
UNITED ARAB EMIRATES	AE	en_AE, fr_AE, es_AE, zh_AE, ar_AE
UNITED KINGDOM	GB	en_GB
UNITED STATES	US	en_US, fr_US, es_US, zh_US
URUGUAY	UY	es_UY, en_UY, fr_UY, zh_UY
VANUATU	VU	en_VU, fr_VU, es_VU, zh_VU
VATICAN CITY	VA	en_VA, fr_VA, es_VA, zh_VA
VENEZUELA	VE	es_VE, en_VE, fr_VE, zh_VE
VIETNAM	VN	en_VN
WALLIS & FUTUNA	WF	en_WF, fr_WF, es_WF, zh_WF
YEMEN	YE	ar_YE, en_YE, fr_YE, es_YE, zh_YE
ZAMBIA	ZM	en_ZM, fr_ZM, es_ZM, zh_ZM
ZIMBABWE	ZW	en_ZW
Merchant ID
The merchant ID of a merchant for whom you are facilitating a transaction.

Use this parameter only for partner, marketplaces, and cart solutions when you are acting on behalf of another merchant to facilitate their PayPal transactions. This parameter is essential to guarantee the merchant sees the best possible combination of PayPal buttons.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&merchant-id=XXX"></script>

Integration	Use case	Client ID	Merchant ID	Other
Standalone integration	I am capturing funds directly into my PayPal account.	Pass a client ID associated with your account.	Do not pass merchant ID (it is automatically derived).	
Partner or Marketplace integration	I am facilitating payments on behalf of other merchants.	Pass a client ID associated with your partner or marketplace account.	You must pass the merchant ID of the merchant for whom you are facilitating payments.	
Cart integration	I am facilitating payments on behalf of other merchants and I have the client IDs for those merchants.	Pass the client ID of the merchant for whom you are facilitating payments.	Do not pass a merchant ID.	Pass the integration date parameter to ensure your integration does not break as new client IDs onboard to your site.
Vault
The vault status of the transaction. Vaulting allows you to store your customers' payment information for billing agreements, subscriptions, or recurring payments.

Note: Not all payment methods can be vaulted.

If the vault status is set to true:

It shows only the funding source you can add to the vault.
Sets up a billing agreement, reference transaction, or subscription.
Defaults to false.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&vault=true"></script>

Option	Description
true	Show only funding sources that you can vault or use to create a billing agreement, subscription, or recurring payment.
false	Show all funding sources.
Script parameters
Script parameters are additional key value pairs you can add to the script tag to provide information you need for your site to work, a nonce, or information you'd like to capture on a page for analytics reasons.

For example, a token that identifies your buyer:

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-client-token="abc123xyz=="></script>

Option	Description
data-csp-nonce	CSP nonce used for rendering the button.
data-client-token	Client token used for identifying your buyers.
data-order-id	Order ID used for optimizing the funding that displays.
data-page-type	Log page type and interactions for the JavaScript SDK.
data-partner-attribution-id	Partner attribution ID used for revenue attribution.
CSP nonce
Pass a Content Security Policy nonce, a one time authorization code or token, if you use them on your site. See Content Security Policy for details.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-csp-nonce="MY_CSP_NONCE"></script>

Client token
Pass a client token if you are integrating with Advanced Card Payments.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-client-token="abc123xyz=="></script>

Order ID
Pass your order ID if you are generating this on the server-side prior to rendering the page. PayPal uses Order ID to help decide the best buttons to display to the buyer.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-order-id="2VW94544JM6797511"></script>

Page type
Pass a page type to log the type of page where the JavaScript SDK loads and any interactions with the components you use. This attribute accepts these page types: product-listing, search-results, product-details, mini-cart, cart or checkout as values.

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-page-type="product-details"></script>

Partner attribution ID
Pass your partner attribution ID, or build notation (BN) code, to receive revenue attribution. Your BN code is issued to you as part of the partner onboarding process and provides tracking on all transactions that originate or are associated with you. To find your BN code:

Log in to the Developer Dashboard with your PayPal account.
In the left-hand navigation menu, select My Apps & Credentials.
Select your app.
Under App Settings, find your BN code.
<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID" data-partner-attribution-id="MY_PARTNER_ATTRIBUTION_ID"></script>

See also
JavaScript SDK complete reference.
Optimize the performance of the JavaScript SDK.
