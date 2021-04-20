import { LightningElement, api, track } from 'lwc';
import fetchsObjectData from '@salesforce/apex/ASI_eForm_HK_CustomerFormController.fetchsObjectData';
import GenerateRefreshToken from '@salesforce/apex/ASI_eForm_HK_CustomerFormController.GenerateRefreshToken';


import HK_LOGO from '@salesforce/resourceUrl/ASI_CRM_HK_Logo';
import PRA_LOGO from '@salesforce/resourceUrl/ASI_eForm_PRA_Logo';
import ATR_LOGO from '@salesforce/resourceUrl/ASI_eForm_ATR_Logo';


export default class Asi_CRM_HK_WebVF_Compt extends LightningElement {

    @api recordId;
    @api formType;
    @track LogId = '';
    @track CompanyName = '';
    @track CompanyShortName = '';
    @track disabledSubmit = true;
    @track disabledNext1 = true;
    @track disabledNext2 = true;
    @track APIobj = {};
    @track progressRate = 0;
    @track ShowProgress = false;
    @track ShowProgressIcon = false;
    @track ProgressInfo = '';

    @track CustomerRecord = {};
    @track currentStep = "1";
    @track isLoaded = true;
    @track FormOwner = '';

    @track DisplayDeliveryField = false;
    @track DisplayBankField = false;


    @track TnC_Chx1 = false;
    @track TnC_Chx2 = false;

    //system information disdplay
    @track displaySysInfo = false;
    @track SysInfoHeader = '';
    @track SysInfoDetail = '';
    @track showError = false;
    @track showSuccess = false;
    @track PaymentMethod = [
        { 'label': 'Cheque', 'value': 'Cheque' },
        { 'label': 'Bank Transfer', 'value': 'Bank Transfer' }
    ];
    @track PhoneFaxOption = [
        { 'label': 'Phone', 'value': 'Phone' },
        { 'label': 'Fax', 'value': 'Fax' },
    ];

    @track CategoryofPurchases = [
        { 'label': 'Agave', 'value': 'Agave' },
        { 'label': 'Capsules', 'value': 'Capsules' },
        { 'label': 'Carton', 'value': 'Carton' },
        { 'label': 'Casks', 'value': 'Casks' },
        { 'label': 'Closures', 'value': 'Closures' },
        { 'label': 'Copacking', 'value': 'Copacking' },
        { 'label': 'Cork', 'value': 'Cork' },
        { 'label': 'Cereals', 'value': 'Cereals' },
        { 'label': 'Consulting', 'value': 'Consulting' },
        { 'label': 'Decoration', 'value': 'Decoration' },
        { 'label': 'Drinkware', 'value': 'Drinkware' },
        { 'label': 'Disposable Display', 'value': 'Disposable Display' },
        { 'label': 'Energy', 'value': 'Energy' },
        { 'label': 'Facility Management', 'value': 'Facility Management' },
        { 'label': 'Fruits & Plants', 'value': 'Fruits & Plants' },
        { 'label': 'Garment & Accessories', 'value': 'Garment & Accessories' },
        { 'label': 'Gifts', 'value': 'Gifts' },
        { 'label': 'Grapes & by products', 'value': 'Grapes & by products' },
        { 'label': 'Gift Boxes', 'value': 'Gift Boxes' },
        { 'label': 'Glass', 'value': 'Glass' },
        { 'label': 'Ingredients', 'value': 'Ingredients' },
        { 'label': 'IT', 'value': 'IT' },
        { 'label': 'Labels', 'value': 'Labels' },
        { 'label': 'Misc. packaging items', 'value': 'Misc. packaging items' },
        { 'label': 'Molasses', 'value': 'Molasses' },
        { 'label': 'Marketing', 'value': 'Marketing' },
        { 'label': 'Other Containers', 'value': 'Other Containers' },
        { 'label': 'Processing Aids', 'value': 'Processing Aids' },
        { 'label': 'Pure Neutral Alcohol & Bulk Finished Alcohol', 'value': 'Pure Neutral Alcohol & Bulk Finished Alcohol' },
        { 'label': 'Pet Bottles', 'value': 'Pet Bottles' },
        { 'label': 'Permanent Visibility', 'value': 'Permanent Visibility' },
        { 'label': 'Print & Multimedia', 'value': 'Print & Multimedia' },
        { 'label': 'Supply Chain', 'value': 'Supply Chain' },
        { 'label': 'Serving Material', 'value': 'Serving Material' },
        { 'label': 'VAP', 'value': 'VAP' }


    ];


    @track PaymentTerm = [
        { 'label': '045-Open A/C 45 Days', 'value': '045-Open A/C 45 Days' },
        { 'label': '060-Open A/C 60 Days', 'value': '060-Open A/C 60 Days' }
    ];


    @track BankCurrency = [
        { 'label': 'ADK-Angola - Kwanza', 'value': 'ADK-Angola - Kwanza' },
        { 'label': 'AED-United Arab Emirates - Dirham', 'value': 'AED-United Arab Emirates - Dirham' },
        { 'label': 'ARP-Argentina - Austral', 'value': 'ARP-Argentina - Austral' },
        { 'label': 'ATS-Austria - Shilling', 'value': 'ATS-Austria - Shilling' },
        { 'label': 'AUD-Australia - Australian Dollar', 'value': 'AUD-Australia - Australian Dollar' },
        { 'label': 'BDT-Bangladesh - Taka', 'value': 'BDT-Bangladesh - Taka' },
        { 'label': 'BEF-Belgium - Franc', 'value': 'BEF-Belgium - Franc' },
        { 'label': 'BGL-Bulgaria - Leva', 'value': 'BGL-Bulgaria - Leva' },
        { 'label': 'BIF-Burundi - Franc', 'value': 'BIF-Burundi - Franc' },
        { 'label': 'BRC-Brasilia - Cruzeiro', 'value': 'BRC-Brasilia - Cruzeiro' },
        { 'label': 'BSD-Bahamas - Dollar', 'value': 'BSD-Bahamas - Dollar' },
        { 'label': 'CAD-Canada - Canadian Dollar', 'value': 'CAD-Canada - Canadian Dollar' },
        { 'label': 'CHF-Switserland - Swiss Frank', 'value': 'CHF-Switserland - Swiss Frank' },
        { 'label': 'CLP-Chili - Peso', 'value': 'CLP-Chili - Peso' },
        { 'label': 'CSK-Czechoslovakia - Crown', 'value': 'CSK-Czechoslovakia - Crown' },
        { 'label': 'CYP-Cyprus - Cyprian Pound', 'value': 'CYP-Cyprus - Cyprian Pound' },
        { 'label': 'DEM-Germany - Deutsch Mark', 'value': 'DEM-Germany - Deutsch Mark' },
        { 'label': 'DKK-Denmark - Danish Crown', 'value': 'DKK-Denmark - Danish Crown' },
        { 'label': 'DZD-Algeria - Dinar', 'value': 'DZD-Algeria - Dinar' },
        { 'label': 'ECS-Ecuador - Sucre', 'value': 'ECS-Ecuador - Sucre' },
        { 'label': 'EGP-Egypt - Egyptian Pound', 'value': 'EGP-Egypt - Egyptian Pound' },
        { 'label': 'ESP-Spain - Spanish Peseta', 'value': 'ESP-Spain - Spanish Peseta' },
        { 'label': 'ETB-Ethiopia - Birr', 'value': 'ETB-Ethiopia - Birr' },
        { 'label': 'EUR-Euro', 'value': 'EUR-Euro' },
        { 'label': 'FEC-Foreign Exchange Currency', 'value': 'FEC-Foreign Exchange Currency' },
        { 'label': 'FIM-Finland - Finnish Mark', 'value': 'FIM-Finland - Finnish Mark' },
        { 'label': 'FRF-France - French Franc', 'value': 'FRF-France - French Franc' },
        { 'label': 'GBP-U.K. - Pound Sterling', 'value': 'GBP-U.K. - Pound Sterling' },
        { 'label': 'GRD-Greece - Drachme', 'value': 'GRD-Greece - Drachme' },
        { 'label': 'HKD-Hong Kong - Hong Kong Dollar', 'value': 'HKD-Hong Kong - Hong Kong Dollar' },
        { 'label': 'HUF-Hungary - Forint', 'value': 'HUF-Hungary - Forint' },
        { 'label': 'IDR-Indonesia - Rupiah', 'value': 'IDR-Indonesia - Rupiah' },
        { 'label': 'IEP-Ireland - Irish Pound', 'value': 'IEP-Ireland - Irish Pound' },
        { 'label': 'ILS-Israel - Shekel', 'value': 'ILS-Israel - Shekel' },
        { 'label': 'INR-India - Indian Rupi', 'value': 'INR-India - Indian Rupi' },
        { 'label': 'IQD-Iraq - Dinar', 'value': 'IQD-Iraq - Dinar' },
        { 'label': 'IRR-Iran - Rial', 'value': 'IRR-Iran - Rial' },
        { 'label': 'ISK-Iceland - Iceland Crown', 'value': 'ISK-Iceland - Iceland Crown' },
        { 'label': 'ITL-Italia - Lira', 'value': 'ITL-Italia - Lira' },
        { 'label': 'JOD-Jordania - Dinar', 'value': 'JOD-Jordania - Dinar' },
        { 'label': 'JPY-Japan - Yen', 'value': 'JPY-Japan - Yen' },
        { 'label': 'KES-Kenia - Shilling', 'value': 'KES-Kenia - Shilling' },
        { 'label': 'KRW-Korean - Korean Won', 'value': 'KRW-Korean - Korean Won' },
        { 'label': 'KWD-Kuwait - Dinar', 'value': 'KWD-Kuwait - Dinar' },
        { 'label': 'LAK-Laos - Kip', 'value': 'LAK-Laos - Kip' },
        { 'label': 'LBP-Libanon - Libanese Pound', 'value': 'LBP-Libanon - Libanese Pound' },
        { 'label': 'LKR-Sri Lanka Rupee', 'value': 'LKR-Sri Lanka Rupee' },
        { 'label': 'LUF-Luxemburg - Lux.Franc', 'value': 'LUF-Luxemburg - Lux.Franc' },
        { 'label': 'LYD-Lybia - Dinar', 'value': 'LYD-Lybia - Dinar' },
        { 'label': 'MAD-Marokko - Dirham', 'value': 'MAD-Marokko - Dirham' },
        { 'label': 'MGF-Madagascar - Frank', 'value': 'MGF-Madagascar - Frank' },
        { 'label': 'MLF-Mali - Frank', 'value': 'MLF-Mali - Frank' },
        { 'label': 'MOP-Macau', 'value': 'MOP-Macau' },
        { 'label': 'MRO-Mauretanie - Ougiya', 'value': 'MRO-Mauretanie - Ougiya' },
        { 'label': 'MTL-Malta - Lira', 'value': 'MTL-Malta - Lira' },
        { 'label': 'MXN-Mexico - Peso', 'value': 'MXN-Mexico - Peso' },
        { 'label': 'MYR-Malaysia - Ringgit', 'value': 'MYR-Malaysia - Ringgit' },
        { 'label': 'NGN-Nigeria - Naira', 'value': 'NGN-Nigeria - Naira' },
        { 'label': 'NLG-Netherlands - Guilders', 'value': 'NLG-Netherlands - Guilders' },
        { 'label': 'NOK-Norway - Norwegian Crown', 'value': 'NOK-Norway - Norwegian Crown' },
        { 'label': 'NPR-Nepal - Rupia', 'value': 'NPR-Nepal - Rupia' },
        { 'label': 'NTD-New Taiwan Dollars', 'value': 'NTD-New Taiwan Dollars' },
        { 'label': 'NZD-New Zealand - New Zeal.Dollar', 'value': 'NZD-New Zealand - New Zeal.Dollar' },
        { 'label': 'OMR-Oman - Rial', 'value': 'OMR-Oman - Rial' },
        { 'label': 'PAB-Panama - Balboa', 'value': 'PAB-Panama - Balboa' },
        { 'label': 'PES-Peru - Sol', 'value': 'PES-Peru - Sol' },
        { 'label': 'PGK-Papoea New Guinea - Kina', 'value': 'PGK-Papoea New Guinea - Kina' },
        { 'label': 'PHP-Philippines - Peso', 'value': 'PHP-Philippines - Peso' },
        { 'label': 'PKR-Pakistan - Rupia', 'value': 'PKR-Pakistan - Rupia' },
        { 'label': 'PLZ-Poland - Zloty', 'value': 'PLZ-Poland - Zloty' },
        { 'label': 'PTE-Portugal - Escudo', 'value': 'PTE-Portugal - Escudo' },
        { 'label': 'PYG-Paraguay - Guarani', 'value': 'PYG-Paraguay - Guarani' },
        { 'label': 'QAR-Qatar - Rial', 'value': 'QAR-Qatar - Rial' },
        { 'label': 'RMB-Reminbi', 'value': 'RMB-Reminbi' },
        { 'label': 'ROL-Rumenia - Leu', 'value': 'ROL-Rumenia - Leu' },
        { 'label': 'RUB-Russian Rouble', 'value': 'RUB-Russian Rouble' },
        { 'label': 'RWF-Rwanda - Rwandese Franc', 'value': 'RWF-Rwanda - Rwandese Franc' },
        { 'label': 'SAR-Saudi Arabia - Riyal', 'value': 'SAR-Saudi Arabia - Riyal' },
        { 'label': 'SEK-Sweden - Swedish Crown', 'value': 'SEK-Sweden - Swedish Crown' },
        { 'label': 'SFR-Switzerland', 'value': 'SFR-Switzerland' },
        { 'label': 'SGD-Singapore - Singapore Dollar', 'value': 'SGD-Singapore - Singapore Dollar' },
        { 'label': 'SUR-USSR - Roebel', 'value': 'SUR-USSR - Roebel' },
        { 'label': 'SYP-Syria - Pound', 'value': 'SYP-Syria - Pound' },
        { 'label': 'THB-Thailand - Bath', 'value': 'THB-Thailand - Bath' },
        { 'label': 'TND-Tunisia - Dinar', 'value': 'TND-Tunisia - Dinar' },
        { 'label': 'TRL-Turky - Pound', 'value': 'TRL-Turky - Pound' },
        { 'label': 'TZS-Tanzania - Shilling', 'value': 'TZS-Tanzania - Shilling' },
        { 'label': 'USD-U.S.A. - Dollar', 'value': 'USD-U.S.A. - Dollar' },
        { 'label': 'VEB-Venezuela - Bolivar', 'value': 'VEB-Venezuela - Bolivar' },
        { 'label': 'VND-Vietnam Dong', 'value': 'VND-Vietnam Dong' },
        { 'label': 'XAF-Centr.Afr.Rep. - CFA', 'value': 'XAF-Centr.Afr.Rep. - CFA' },
        { 'label': 'XDF-Ivory Coast - CFA', 'value': 'XDF-Ivory Coast - CFA' },
        { 'label': 'XEU-Europe - Ecu', 'value': 'XEU-Europe - Ecu' },
        { 'label': 'YUD-Yugoslavia - Dinar', 'value': 'YUD-Yugoslavia - Dinar' },
        { 'label': 'ZAR-South Africa - Rand', 'value': 'ZAR-South Africa - Rand' },
        { 'label': 'ZMK-Zambia - Kwacha', 'value': 'ZMK-Zambia - Kwacha' },
        { 'label': 'ZRZ-Zaire - Zaire', 'value': 'ZRZ-Zaire - Zaire' },
        { 'label': 'ZWD-Zimbabwe - Dollar', 'value': 'ZWD-Zimbabwe - Dollar' }
    ];

    @track CountryList = [
        { 'label': 'AA-ARUBA', 'value': 'AA-ARUBA' },
        { 'label': 'AD-ANDORRA', 'value': 'AD-ANDORRA' },
        { 'label': 'AE-UNITED ARAB EMIRATES (UAE)', 'value': 'AE-UNITED ARAB EMIRATES (UAE)' },
        { 'label': 'AF-AFGHANISTAN', 'value': 'AF-AFGHANISTAN' },
        { 'label': 'AG-ANTIQUA AND BARBUDA', 'value': 'AG-ANTIQUA AND BARBUDA' },
        { 'label': 'AI-ANQUILLA', 'value': 'AI-ANQUILLA' },
        { 'label': 'AL-ALBANIA', 'value': 'AL-ALBANIA' },
        { 'label': 'AM-ARMENIA', 'value': 'AM-ARMENIA' },
        { 'label': 'AN-NETHERLANDS ANTILLES', 'value': 'AN-NETHERLANDS ANTILLES' },
        { 'label': 'AO-ANGLOA (INCLUDING CABINDA)', 'value': 'AO-ANGLOA (INCLUDING CABINDA)' },
        { 'label': 'AQ-ANTARCTICA', 'value': 'AQ-ANTARCTICA' },
        { 'label': 'AR-ARGENTINA', 'value': 'AR-ARGENTINA' },
        { 'label': 'AS-AMERICAN SAMOA', 'value': 'AS-AMERICAN SAMOA' },
        { 'label': 'AT-AUSTRIA(EX.JUNGHOLZ&MITTEBLERG', 'value': 'AT-AUSTRIA(EX.JUNGHOLZ&MITTEBLERG' },
        { 'label': 'AU-AUSTRALIA', 'value': 'AU-AUSTRALIA' },
        { 'label': 'AW-ARUBA', 'value': 'AW-ARUBA' },
        { 'label': 'AZ-AZERBAIJAN', 'value': 'AZ-AZERBAIJAN' },
        { 'label': 'BA-BOSNIA AND HERZEGOVINA', 'value': 'BA-BOSNIA AND HERZEGOVINA' },
        { 'label': 'BB-BARBADOS', 'value': 'BB-BARBADOS' },
        { 'label': 'BD-BANGLADESH', 'value': 'BD-BANGLADESH' },
        { 'label': 'BE-BELGIUM', 'value': 'BE-BELGIUM' },
        { 'label': 'BF-BURKINA FASO', 'value': 'BF-BURKINA FASO' },
        { 'label': 'BG-BULGARIA', 'value': 'BG-BULGARIA' },
        { 'label': 'BH-BAHRAIN', 'value': 'BH-BAHRAIN' },
        { 'label': 'BI-BURUNDI', 'value': 'BI-BURUNDI' },
        { 'label': 'BJ-BENIN', 'value': 'BJ-BENIN' },
        { 'label': 'BK-BURKINA', 'value': 'BK-BURKINA' },
        { 'label': 'BM-BERMUDA', 'value': 'BM-BERMUDA' },
        { 'label': 'BN-BRUNEI', 'value': 'BN-BRUNEI' },
        { 'label': 'BO-BOLIVIA', 'value': 'BO-BOLIVIA' },
        { 'label': 'BQ-BRITISH ANTARCTIC TERRITORY', 'value': 'BQ-BRITISH ANTARCTIC TERRITORY' },
        { 'label': 'BR-BRAZIL', 'value': 'BR-BRAZIL' },
        { 'label': 'BS-BAHAMAS', 'value': 'BS-BAHAMAS' },
        { 'label': 'BT-BHUTAN', 'value': 'BT-BHUTAN' },
        { 'label': 'BU-BURMA', 'value': 'BU-BURMA' },
        { 'label': 'BV-BOUVET ISLAND', 'value': 'BV-BOUVET ISLAND' },
        { 'label': 'BW-BOTSWANA', 'value': 'BW-BOTSWANA' },
        { 'label': 'BY-BYELORUSSIAN SSR', 'value': 'BY-BYELORUSSIAN SSR' },
        { 'label': 'BZ-BELIZE', 'value': 'BZ-BELIZE' },
        { 'label': 'CA-CANADA', 'value': 'CA-CANADA' },
        { 'label': 'CC-COCOS (KEELING) ISLANDS', 'value': 'CC-COCOS (KEELING) ISLANDS' },
        { 'label': 'CD-DEMOCRATIC REPUBLIC OF CONGO', 'value': 'CD-DEMOCRATIC REPUBLIC OF CONGO' },
        { 'label': 'CF-CENTRAL AFRICAN REPUBLIC', 'value': 'CF-CENTRAL AFRICAN REPUBLIC' },
        { 'label': 'CG-CONGO', 'value': 'CG-CONGO' },
        { 'label': 'CH-SWITZERLAND', 'value': 'CH-SWITZERLAND' },
        { 'label': 'CI-IVORY COAST', 'value': 'CI-IVORY COAST' },
        { 'label': 'CK-COOK ISLANDS', 'value': 'CK-COOK ISLANDS' },
        { 'label': 'CL-CHILE', 'value': 'CL-CHILE' },
        { 'label': 'CM-CAMEROON', 'value': 'CM-CAMEROON' },
        { 'label': 'CN-CHINA', 'value': 'CN-CHINA' },
        { 'label': 'CO-COLOMBIA', 'value': 'CO-COLOMBIA' },
        { 'label': 'CR-COSTA RICA', 'value': 'CR-COSTA RICA' },
        { 'label': 'CS-CZECHOSLOVAKIA', 'value': 'CS-CZECHOSLOVAKIA' },
        { 'label': 'CU-CUBA', 'value': 'CU-CUBA' },
        { 'label': 'CV-CAPE VERDE', 'value': 'CV-CAPE VERDE' },
        { 'label': 'CX-CHRISTMAS ISLAND', 'value': 'CX-CHRISTMAS ISLAND' },
        { 'label': 'CY-CYPRUS', 'value': 'CY-CYPRUS' },
        { 'label': 'CZ-AUSTRALIAN OCEANIA', 'value': 'CZ-AUSTRALIAN OCEANIA' },
        { 'label': 'DE-GERMANY (DEUTSCHLAND)', 'value': 'DE-GERMANY (DEUTSCHLAND)' },
        { 'label': 'DEL-DELHI', 'value': 'DEL-DELHI' },
        { 'label': 'DH-ABU DHABI', 'value': 'DH-ABU DHABI' },
        { 'label': 'DJ-DJIBOUTI', 'value': 'DJ-DJIBOUTI' },
        { 'label': 'DK-DENMARK', 'value': 'DK-DENMARK' },
        { 'label': 'DM-DOMINICA', 'value': 'DM-DOMINICA' },
        { 'label': 'DO-DOMINICAN REPUBLIC', 'value': 'DO-DOMINICAN REPUBLIC' },
        { 'label': 'DU-DUBAI', 'value': 'DU-DUBAI' },
        { 'label': 'DUB-DUBAI', 'value': 'DUB-DUBAI' },
        { 'label': 'DZ-ALGERIA', 'value': 'DZ-ALGERIA' },
        { 'label': 'EC-ECUADOR', 'value': 'EC-ECUADOR' },
        { 'label': 'EE-ESTONIA', 'value': 'EE-ESTONIA' },
        { 'label': 'EG-EGYPT', 'value': 'EG-EGYPT' },
        { 'label': 'EH-WESTERN SAHARA', 'value': 'EH-WESTERN SAHARA' },
        { 'label': 'ER-ERITREA', 'value': 'ER-ERITREA' },
        { 'label': 'ES-SPAIN', 'value': 'ES-SPAIN' },
        { 'label': 'ET-ETHIOPIA', 'value': 'ET-ETHIOPIA' },
        { 'label': 'FI-FINLAND', 'value': 'FI-FINLAND' },
        { 'label': 'FJ-FIJI', 'value': 'FJ-FIJI' },
        { 'label': 'FK-FALKLAND ISLANDS', 'value': 'FK-FALKLAND ISLANDS' },
        { 'label': 'FL-LIECHTENSTEIN', 'value': 'FL-LIECHTENSTEIN' },
        { 'label': 'FM-MICRONESIA', 'value': 'FM-MICRONESIA' },
        { 'label': 'FO-FAROE ISLANDS', 'value': 'FO-FAROE ISLANDS' },
        { 'label': 'FQ-FRENCH SOUTHERN TERRITORY', 'value': 'FQ-FRENCH SOUTHERN TERRITORY' },
        { 'label': 'FR-FRANCE', 'value': 'FR-FRANCE' },
        { 'label': 'GA-GABON', 'value': 'GA-GABON' },
        { 'label': 'GB-UNITED KINGDOM (GREAT BRITAIN)', 'value': 'GB-UNITED KINGDOM (GREAT BRITAIN)' },
        { 'label': 'GD-GRENADA', 'value': 'GD-GRENADA' },
        { 'label': 'GE-GEORGIA', 'value': 'GE-GEORGIA' },
        { 'label': 'GF-FRENCH GUIANA', 'value': 'GF-FRENCH GUIANA' },
        { 'label': 'GH-GHANA', 'value': 'GH-GHANA' },
        { 'label': 'GI-GIBRALTAR', 'value': 'GI-GIBRALTAR' },
        { 'label': 'GL-GREENLAND', 'value': 'GL-GREENLAND' },
        { 'label': 'GM-GAMBIA', 'value': 'GM-GAMBIA' },
        { 'label': 'GN-GUINEA', 'value': 'GN-GUINEA' },
        { 'label': 'GP-DESIRADE', 'value': 'GP-DESIRADE' },
        { 'label': 'GQ-EQUATORIAL GUINEA', 'value': 'GQ-EQUATORIAL GUINEA' },
        { 'label': 'GR-GREECE', 'value': 'GR-GREECE' },
        { 'label': 'GS-GUERNSEY', 'value': 'GS-GUERNSEY' },
        { 'label': 'GT-GUATEMALA', 'value': 'GT-GUATEMALA' },
        { 'label': 'GU-GUAM', 'value': 'GU-GUAM' },
        { 'label': 'GW-GUINEA-BISSAY', 'value': 'GW-GUINEA-BISSAY' },
        { 'label': 'GY-GUYANA', 'value': 'GY-GUYANA' },
        { 'label': 'HA-AJMAN', 'value': 'HA-AJMAN' },
        { 'label': 'HAR-HARYANA', 'value': 'HAR-HARYANA' },
        { 'label': 'HK-HONG KONG', 'value': 'HK-HONG KONG' },
        { 'label': 'HM-HEARD ISLAND AND MCDONALD ISLA', 'value': 'HM-HEARD ISLAND AND MCDONALD ISLA' },
        { 'label': 'HN-HONDURAS', 'value': 'HN-HONDURAS' },
        { 'label': 'HR-CROATIA', 'value': 'HR-CROATIA' },
        { 'label': 'HT-HAITI', 'value': 'HT-HAITI' },
        { 'label': 'HU-HUNGARY', 'value': 'HU-HUNGARY' },
        { 'label': 'IC-CANARY ISLANDS', 'value': 'IC-CANARY ISLANDS' },
        { 'label': 'ID-INDONESIA', 'value': 'ID-INDONESIA' },
        { 'label': 'IE-IRISH REPUBLIC', 'value': 'IE-IRISH REPUBLIC' },
        { 'label': 'IL-ISRAEL', 'value': 'IL-ISRAEL' },
        { 'label': 'IM-MAN, ISLE OF', 'value': 'IM-MAN, ISLE OF' },
        { 'label': 'IN-INDIA', 'value': 'IN-INDIA' },
        { 'label': 'IO-BRITISH INDIAN OCEAN TERR.', 'value': 'IO-BRITISH INDIAN OCEAN TERR.' },
        { 'label': 'IQ-IRAG', 'value': 'IQ-IRAG' },
        { 'label': 'IR-IRAN', 'value': 'IR-IRAN' },
        { 'label': 'IS-ICELAND', 'value': 'IS-ICELAND' },
        { 'label': 'IT-ITALY', 'value': 'IT-ITALY' },
        { 'label': 'JM-JAMAICA', 'value': 'JM-JAMAICA' },
        { 'label': 'JO-JORDAN', 'value': 'JO-JORDAN' },
        { 'label': 'JP-JAPAN', 'value': 'JP-JAPAN' },
        { 'label': 'JS-JERSEY', 'value': 'JS-JERSEY' },
        { 'label': 'KAR-KARNATAKA', 'value': 'KAR-KARNATAKA' },
        { 'label': 'KE-KENYA', 'value': 'KE-KENYA' },
        { 'label': 'KER-KERALA', 'value': 'KER-KERALA' },
        { 'label': 'KG-KYRGYZSTAN', 'value': 'KG-KYRGYZSTAN' },
        { 'label': 'KH-KAMPUCHEA (CAMBODIA)', 'value': 'KH-KAMPUCHEA (CAMBODIA)' },
        { 'label': 'KI-KIRIBATI', 'value': 'KI-KIRIBATI' },
        { 'label': 'KM-COMOROS', 'value': 'KM-COMOROS' },
        { 'label': 'KN-ST. CHRISTOPHER AND NEVIS', 'value': 'KN-ST. CHRISTOPHER AND NEVIS' },
        { 'label': 'KP-KOREA, NORTH', 'value': 'KP-KOREA, NORTH' },
        { 'label': 'KR-KOREA', 'value': 'KR-KOREA' },
        { 'label': 'KW-KUWAIT', 'value': 'KW-KUWAIT' },
        { 'label': 'KY-CAYMAN ISLANDS', 'value': 'KY-CAYMAN ISLANDS' },
        { 'label': 'KZ-KAZAKHSTAN', 'value': 'KZ-KAZAKHSTAN' },
        { 'label': 'LA-LAOS', 'value': 'LA-LAOS' },
        { 'label': 'LB-LEBANON', 'value': 'LB-LEBANON' },
        { 'label': 'LC-ST. LUCIA', 'value': 'LC-ST. LUCIA' },
        { 'label': 'LI-LIECHTENSTEIN', 'value': 'LI-LIECHTENSTEIN' },
        { 'label': 'LK-SRI LANKA', 'value': 'LK-SRI LANKA' },
        { 'label': 'LR-LIBERIA', 'value': 'LR-LIBERIA' },
        { 'label': 'LS-LESOTHO', 'value': 'LS-LESOTHO' },
        { 'label': 'LT-LITHUANIA', 'value': 'LT-LITHUANIA' },
        { 'label': 'LU-LUXEMBOURG', 'value': 'LU-LUXEMBOURG' },
        { 'label': 'LV-LATVIA', 'value': 'LV-LATVIA' },
        { 'label': 'LY-LIBYA', 'value': 'LY-LIBYA' },
        { 'label': 'MA-MOROCCA', 'value': 'MA-MOROCCA' },
        { 'label': 'MAH-MAHARASHTRA', 'value': 'MAH-MAHARASHTRA' },
        { 'label': 'MC-MONACO', 'value': 'MC-MONACO' },
        { 'label': 'MD-MOLDOVA, REPUBLIC OF', 'value': 'MD-MOLDOVA, REPUBLIC OF' },
        { 'label': 'ME-MAYOTTE', 'value': 'ME-MAYOTTE' },
        { 'label': 'MG-MADAGASCAR (MALAGASY REPUBLIC)', 'value': 'MG-MADAGASCAR (MALAGASY REPUBLIC)' },
        { 'label': 'MH-MARSHALL ISLANDS', 'value': 'MH-MARSHALL ISLANDS' },
        { 'label': 'MK-MACEDONIA, THE FORMER YUGOSLAV', 'value': 'MK-MACEDONIA, THE FORMER YUGOSLAV' },
        { 'label': 'ML-MALI', 'value': 'ML-MALI' },
        { 'label': 'MM-MYANMAR', 'value': 'MM-MYANMAR' },
        { 'label': 'MN-MONGOLIA', 'value': 'MN-MONGOLIA' },
        { 'label': 'MO-MACAO', 'value': 'MO-MACAO' },
        { 'label': 'MP-NORTHERN MARIANA ISLANDS', 'value': 'MP-NORTHERN MARIANA ISLANDS' },
        { 'label': 'MQ-MARTINIQUE', 'value': 'MQ-MARTINIQUE' },
        { 'label': 'MR-MAURITANIA', 'value': 'MR-MAURITANIA' },
        { 'label': 'MS-MONTSERRAT', 'value': 'MS-MONTSERRAT' },
        { 'label': 'MT-MALTA', 'value': 'MT-MALTA' },
        { 'label': 'MU-MAURITIUS', 'value': 'MU-MAURITIUS' },
        { 'label': 'MV-MALDIVES', 'value': 'MV-MALDIVES' },
        { 'label': 'MW-MALAWI', 'value': 'MW-MALAWI' },
        { 'label': 'MX-MEXICO', 'value': 'MX-MEXICO' },
        { 'label': 'MY-MALAYSIA', 'value': 'MY-MALAYSIA' },
        { 'label': 'MZ-MOZAMBIQUE', 'value': 'MZ-MOZAMBIQUE' },
        { 'label': 'NA-SOUTH WEST AFRICA (NAMIBIA)', 'value': 'NA-SOUTH WEST AFRICA (NAMIBIA)' },
        { 'label': 'NC-NEW CALEDONIA AND DEPENDENCIES', 'value': 'NC-NEW CALEDONIA AND DEPENDENCIES' },
        { 'label': 'NE-NIGER', 'value': 'NE-NIGER' },
        { 'label': 'NF-NORFOLK ISLAND', 'value': 'NF-NORFOLK ISLAND' },
        { 'label': 'NG-NIGERIA', 'value': 'NG-NIGERIA' },
        { 'label': 'NI-NICARAQUA', 'value': 'NI-NICARAQUA' },
        { 'label': 'NL-NETHERLANDS', 'value': 'NL-NETHERLANDS' },
        { 'label': 'NN-NONE', 'value': 'NN-NONE' },
        { 'label': 'NO-NORWAY', 'value': 'NO-NORWAY' },
        { 'label': 'NP-NEPAL', 'value': 'NP-NEPAL' },
        { 'label': 'NR-NAURU', 'value': 'NR-NAURU' },
        { 'label': 'NU-NIUE', 'value': 'NU-NIUE' },
        { 'label': 'NZ-NEW ZEALAND', 'value': 'NZ-NEW ZEALAND' },
        { 'label': 'OK-OKINAWA', 'value': 'OK-OKINAWA' },
        { 'label': 'OM-OMAN', 'value': 'OM-OMAN' },
        { 'label': 'OT-OCCUPIED TERRITORIES', 'value': 'OT-OCCUPIED TERRITORIES' },
        { 'label': 'PA-PANAMA', 'value': 'PA-PANAMA' },
        { 'label': 'PC-PACIFIC', 'value': 'PC-PACIFIC' },
        { 'label': 'PE-PERU', 'value': 'PE-PERU' },
        { 'label': 'PF-FRENCH POLYNESIA', 'value': 'PF-FRENCH POLYNESIA' },
        { 'label': 'PG-PAPUA NEW GUINEA', 'value': 'PG-PAPUA NEW GUINEA' },
        { 'label': 'PH-PHILIPPINES', 'value': 'PH-PHILIPPINES' },
        { 'label': 'PK-PAKISTAN', 'value': 'PK-PAKISTAN' },
        { 'label': 'PL-POLAND', 'value': 'PL-POLAND' },
        { 'label': 'PM-ST. PIERRE AND MIQUELON', 'value': 'PM-ST. PIERRE AND MIQUELON' },
        { 'label': 'PN-PITCAIRN ISLAND', 'value': 'PN-PITCAIRN ISLAND' },
        { 'label': 'PR-PUERTO RICO', 'value': 'PR-PUERTO RICO' },
        { 'label': 'PS-PALESTINIAN TERRITORY, OCCUPIE', 'value': 'PS-PALESTINIAN TERRITORY, OCCUPIE' },
        { 'label': 'PT-PORTUGAL', 'value': 'PT-PORTUGAL' },
        { 'label': 'PU-AMERICAN SAMOA', 'value': 'PU-AMERICAN SAMOA' },
        { 'label': 'PW-PALAU', 'value': 'PW-PALAU' },
        { 'label': 'PY-PARAGUAY', 'value': 'PY-PARAGUAY' },
        { 'label': 'QA-QATAR', 'value': 'QA-QATAR' },
        { 'label': 'QQ-BONAIRE', 'value': 'QQ-BONAIRE' },
        { 'label': 'RE-REUNION', 'value': 'RE-REUNION' },
        { 'label': 'RO-ROMANIA', 'value': 'RO-ROMANIA' },
        { 'label': 'RU-RUSSIA', 'value': 'RU-RUSSIA' },
        { 'label': 'RW-RWANDA', 'value': 'RW-RWANDA' },
        { 'label': 'SA-SAUDI ARABIA', 'value': 'SA-SAUDI ARABIA' },
        { 'label': 'SB-SOLOMON ISLANDS', 'value': 'SB-SOLOMON ISLANDS' },
        { 'label': 'SC-SEYCHELLES', 'value': 'SC-SEYCHELLES' },
        { 'label': 'SD-SUDAN', 'value': 'SD-SUDAN' },
        { 'label': 'SE-SWEDEN', 'value': 'SE-SWEDEN' },
        { 'label': 'SG-SINGAPORE', 'value': 'SG-SINGAPORE' },
        { 'label': 'SH-ASCENSION', 'value': 'SH-ASCENSION' },
        { 'label': 'SI-SLOVENIA', 'value': 'SI-SLOVENIA' },
        { 'label': 'SJ-SVALBARD AND JAN MAYEN', 'value': 'SJ-SVALBARD AND JAN MAYEN' },
        { 'label': 'SK-SLOVAKIA', 'value': 'SK-SLOVAKIA' },
        { 'label': 'SL-SIERRA LEONE', 'value': 'SL-SIERRA LEONE' },
        { 'label': 'SM-SAN MARINO', 'value': 'SM-SAN MARINO' },
        { 'label': 'SN-SENEGAL', 'value': 'SN-SENEGAL' },
        { 'label': 'SO-SOMALIA', 'value': 'SO-SOMALIA' },
        { 'label': 'SR-SURINAM', 'value': 'SR-SURINAM' },
        { 'label': 'ST-SAO TOME AND PRINCIPE', 'value': 'ST-SAO TOME AND PRINCIPE' },
        { 'label': 'SU-SOVIET UNION', 'value': 'SU-SOVIET UNION' },
        { 'label': 'SV-EL SALVADOR', 'value': 'SV-EL SALVADOR' },
        { 'label': 'SY-SYRIA', 'value': 'SY-SYRIA' },
        { 'label': 'SZ-SWITZERLAND', 'value': 'SZ-SWITZERLAND' },
        { 'label': 'TC-TURKS AND CAICOS ISLANDS', 'value': 'TC-TURKS AND CAICOS ISLANDS' },
        { 'label': 'TD-CHAD', 'value': 'TD-CHAD' },
        { 'label': 'TF-FRENCH SOUTHERN TERRITORIES', 'value': 'TF-FRENCH SOUTHERN TERRITORIES' },
        { 'label': 'TG-TOGO', 'value': 'TG-TOGO' },
        { 'label': 'TH-THAILAND', 'value': 'TH-THAILAND' },
        { 'label': 'TJ-TAJIKISTAN', 'value': 'TJ-TAJIKISTAN' },
        { 'label': 'TK-TOKELAU', 'value': 'TK-TOKELAU' },
        { 'label': 'TL-TIMOR-LESTE', 'value': 'TL-TIMOR-LESTE' },
        { 'label': 'TM-TURKMENISTAN', 'value': 'TM-TURKMENISTAN' },
        { 'label': 'TN-TUNISIA', 'value': 'TN-TUNISIA' },
        { 'label': 'TO-TONGA', 'value': 'TO-TONGA' },
        { 'label': 'TR-TURKEY', 'value': 'TR-TURKEY' },
        { 'label': 'TT-TRINIDAD AND TOBAQO', 'value': 'TT-TRINIDAD AND TOBAQO' },
        { 'label': 'TV-TUVALU', 'value': 'TV-TUVALU' },
        { 'label': 'TW-TAIWAN', 'value': 'TW-TAIWAN' },
        { 'label': 'TZ-TANZANIA', 'value': 'TZ-TANZANIA' },
        { 'label': 'UA-UNITED ARAB EMIRATES', 'value': 'UA-UNITED ARAB EMIRATES' },
        { 'label': 'UG-UGANDA', 'value': 'UG-UGANDA' },
        { 'label': 'UM-UNITED STATES MINOR OUTLYING I', 'value': 'UM-UNITED STATES MINOR OUTLYING I' },
        { 'label': 'US-UNITED STATES OF AMERICA', 'value': 'US-UNITED STATES OF AMERICA' },
        { 'label': 'UTP-UTTAR PRADESH', 'value': 'UTP-UTTAR PRADESH' },
        { 'label': 'UY-URUGUAY', 'value': 'UY-URUGUAY' },
        { 'label': 'UZ-UZBEKISTAN', 'value': 'UZ-UZBEKISTAN' },
        { 'label': 'VA-VATICAN CITY', 'value': 'VA-VATICAN CITY' },
        { 'label': 'VC-ST. VINCENT', 'value': 'VC-ST. VINCENT' },
        { 'label': 'VE-VENEZUELA', 'value': 'VE-VENEZUELA' },
        { 'label': 'VG-BRITICH VIRGIN ISLANDS', 'value': 'VG-BRITICH VIRGIN ISLANDS' },
        { 'label': 'VI-VIRGIN ISLANDS OF USA', 'value': 'VI-VIRGIN ISLANDS OF USA' },
        { 'label': 'VN-VIETNAM', 'value': 'VN-VIETNAM' },
        { 'label': 'VU-VINUATU', 'value': 'VU-VINUATU' },
        { 'label': 'WF-WALLIS AND FUTUNA ISLANDS', 'value': 'WF-WALLIS AND FUTUNA ISLANDS' },
        { 'label': 'WS-WESTERN SAMOA', 'value': 'WS-WESTERN SAMOA' },
        { 'label': 'XA-AUSTRLAIAN ANTARCTIC TERRITORY', 'value': 'XA-AUSTRLAIAN ANTARCTIC TERRITORY' },
        { 'label': 'XF-FRENCH ANTARCTIC TERRITORY', 'value': 'XF-FRENCH ANTARCTIC TERRITORY' },
        { 'label': 'XI-CEUTA AND MELILLA', 'value': 'XI-CEUTA AND MELILLA' },
        { 'label': 'XR-ROSS DEPENDENCY', 'value': 'XR-ROSS DEPENDENCY' },
        { 'label': 'XT-CORN ISLANDS', 'value': 'XT-CORN ISLANDS' },
        { 'label': 'YE-YEMEN, NORTH', 'value': 'YE-YEMEN, NORTH' },
        { 'label': 'YS-YEMEN, SOUTH', 'value': 'YS-YEMEN, SOUTH' },
        { 'label': 'YT-MAYOTTE', 'value': 'YT-MAYOTTE' },
        { 'label': 'YU-YUGOSLAVIA', 'value': 'YU-YUGOSLAVIA' },
        { 'label': 'ZA-SOUTH AFRICA', 'value': 'ZA-SOUTH AFRICA' },
        { 'label': 'ZB-BELGIAN SECTOR', 'value': 'ZB-BELGIAN SECTOR' },
        { 'label': 'ZD-DANISH SECTOR', 'value': 'ZD-DANISH SECTOR' },
        { 'label': 'ZE-IRISH SECTOR', 'value': 'ZE-IRISH SECTOR' },
        { 'label': 'ZF-FRENCH SECTOR', 'value': 'ZF-FRENCH SECTOR' },
        { 'label': 'ZG-GERMAN SECTOR', 'value': 'ZG-GERMAN SECTOR' },
        { 'label': 'ZH-NETHERLANDS SECTOR', 'value': 'ZH-NETHERLANDS SECTOR' },
        { 'label': 'ZM-ZAMBIA', 'value': 'ZM-ZAMBIA' },
        { 'label': 'ZN-NORWEIGINA SECTOR', 'value': 'ZN-NORWEIGINA SECTOR' },
        { 'label': 'ZR-ZAIRE', 'value': 'ZR-ZAIRE' },
        { 'label': 'ZU-UNITED KINGDOM SECTOR', 'value': 'ZU-UNITED KINGDOM SECTOR' },
        { 'label': 'ZW-ZIMBABWE', 'value': 'ZW-ZIMBABWE' }
    ];

    MAX_FILE_SIZE = 3000000; // 5000000   
    fileReader;

    BRfileContents;
    BankContents;
    //CSRContents;
    SignatureChopContents

    @track BRFileName = '';
    @track BankFileName = '';
    // @track RFIform = '';

    @track SignatureChopFileName = '';
    @track CSRFormURL = '';

    formHeadLogoUrl = HK_LOGO;

    renderedCallback() {

        if (this.Initialized) {
            return;
        }
        this.Initialized = true; // console.log(' log20200511 0.1');
        Promise.all([
        ]).then(() => {
            this.initialize();
        }).catch(error => {
            console.log('form input res load fail!!!!!');
            console.log(error);
            if (error != null) {
                console.log(error.message);
            }
        });

    }

    initialize() {
        if (this.formType == 'Asia') {
            this.formHeadLogoUrl = PRA_LOGO;
            this.CompanyName = 'Pernod Ricard Asia';
            this.CompanyShortName = 'PRA';
        } else if (this.formType == 'ATR') {
            this.formHeadLogoUrl = ATR_LOGO;
            this.CompanyName = 'Pernod Ricard Travel Retail Asia';
            this.CompanyShortName = 'PRTRA';
        } else {
            this.formHeadLogoUrl = HK_LOGO;
            this.CompanyName = 'Pernod Ricard Hong Kong & Macau';
            this.CompanyShortName = 'PRHK&M';
        }


        GenerateRefreshToken().then(result => {
            this.APIobj = JSON.parse(result);
            var requestOptions = {
                method: 'Get',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                redirect: 'follow'
            };

            return fetch(this.APIobj.instance_url + "/services/data/v47.0/sobjects/ASI_eForm_Vendor_Form__c/" + this.recordId, requestOptions);
        }).then(response => response.text()).then(result => {//var sqlstr = "Select Id, ASI_eForm_Webform__c from ASI_eForm_Vendor_Form__c where id='" + this.recordId + "'";
            var resultObj = JSON.parse(result);  //fetchsObjectData({ soqlStatement: sqlstr }).then(result => {
            if (resultObj.ASI_eForm_Webform__c) { // true, not allow to open form 
                this.ShowErrorInfo('You already submitted this eform.');
                this.currentStep = '4';
            } else {
                this.FormOwner = '';//result[0].Owner.Name;
                this.CustomerRecord.ASI_eForm_Payment_Term__c = '045-Open A/C 45 Days';
                this.CustomerRecord.ASI_eForm_Prefix_1__c = '852';
                this.CustomerRecord.ASI_eForm_Prefix_2__c = '852';
                this.CustomerRecord.ASI_eForm_Default_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar';
                this.CustomerRecord.ASI_eForm_Webform_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar';
                this.CustomerRecord.ASI_eForm_Country__c = 'HK-HONG KONG';
                this.CustomerRecord.ASI_eForm_Phone_Fax_1__c = 'Phone';
                this.CustomerRecord.ASI_eForm_Phone_Fax_2__c = 'Fax';

            }
            this.isLoaded = false;
            var sqlstr = 'select id,ASI_eForm_HK_CSR_form_URL__c from ASI_MFM_Setting__c';
            return fetchsObjectData({ soqlStatement: sqlstr });
        }).then(result => {
            this.CSRFormURL = result[0].ASI_eForm_HK_CSR_form_URL__c;
            console.log( this.CSRFormURL );
        }).catch(error => {
            console.log('***** fetchsObjectData failed*******');
            this.displaySysInfo = true;
            this.SysInfoHeader = 'Error';
            this.SysInfoDetail = error;
            this.showError = true;
            console.log(error);
        });

    }

    //***********************Status change******************************************************************************************* */
    get DisplayCustomerInformation() {
        return this.currentStep === "1";
    }
    get Page1() {
        return this.currentStep === "1";
    }
    get Page2() {
        return this.currentStep === "2";
    }
    get Page3() {
        return this.currentStep === "3";
    }

    get DisplayPreviousButton() { // 2 3 
        return this.currentStep === "2" || this.currentStep === "3";
    }

    handleNext() {
        this.resetData();
        switch (this.currentStep) {
            case "1":
                this.currentStep = "2";
                this.handlePage2changes();
                break;
            case "2":
                this.currentStep = "3";
                break;
            default:
                this.currentStep = "1";
                break;
        }
    }

    handlePrevious() {
        this.disabledSubmit = true;
        switch (this.currentStep) {
            case "3":
                this.currentStep = "2";
                break;
            case "2":
                this.currentStep = "1";
                break;
            default:
                this.currentStep = "1";
                break;
        }
    }


    handlePage2changes() {
        GenerateRefreshToken().then(result => {
            var InsertObj = {
                "ASI_MFM_Configuration__c": JSON.stringify(this.CustomerRecord),
                "ASI_CRM_Vendor_Form__c": this.recordId
            }

            this.APIobj = JSON.parse(result);
            var requestOptions = {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(InsertObj),
                redirect: 'follow'
            };
            return fetch(this.APIobj.instance_url + "/services/data/v20.0/sobjects/ASI_MFM_Mass_Upload_Log__c/" , requestOptions);
        }).then(res  => {
            return res.json();
        }).then(result  => {
            if(result.success){
                this.LogId = result.id;
            }
        }).catch(error => {
            console.log('*****failed*******');
            console.log(error);
        });
    }


    handleUpload(event) {//console.log(' ** handleUpload ** ');
        this.showError = false;
        this.displaySysInfo = false;
        var inputId = event.target.id;
        var filename = event.target.files[0].name;
        var filesize = event.target.files[0].size;

        this.fileReader = new FileReader();//console.log('Size : ' + filesize + '   id : ' + event.target.id);
        if (filesize > this.MAX_FILE_SIZE) {
            console.log('Size too large  ');
            this.ShowErrorInfo('Size too large, please select file size<=3M.');
            return;
        }

        this.fileReader.onloadend = (() => {
            var fileContents = this.fileReader.result;
            let base64 = 'base64,';
            var content = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(content);

            if (inputId.includes("Upload_Company_BR")) {
                this.BRfileContents = fileContents;
                this.BRFileName = filename;
            } else if (inputId.includes("Upload_Bank")) {
                this.BankContents = fileContents;
                this.BankFileName = filename;
            } else if (inputId.includes("Upload_SignatureChopFile")) {
                this.SignatureChopContents = fileContents;
                this.SignatureChopFileName = filename;
            }

            if (this.BRfileContents) { //&& this.CSRContents
                if (this.DisplayBankField && !this.BankContents) {
                    this.disabledNext2 = true;
                }
                else {
                    this.disabledNext2 = false;
                }
            } else {
                this.disabledNext1 = true;
            }

            this.handleFilechanges(filename,fileContents);
        });
        this.fileReader.readAsDataURL(event.target.files[0]);
    }

    
    handleFilechanges(FN,fileContent) {
        console.log('LogId : '+ this.LogId);
        if(this.LogId!=''){
            GenerateRefreshToken().then(result => {
                this.APIobj = JSON.parse(result);
                var requestOptions = {
                    method: 'PATCH',
                    headers: {
                        'Authorization': 'Bearer ' + this.APIobj.access_token,
                        'X-PrettyPrint': '1',
                        'Content-Type': 'application/json'
                    },
                    body: encodeURIComponent(fileContent),
                    redirect: 'follow'
                };
                fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.LogId + ':'  + FN, requestOptions);
            }).catch(error => {
                console.log('*****failed*******');
                console.log(error);
            });
        }
    }

    handleFormInputChange(event) { // input field change
        var fieldname = event.currentTarget.dataset.field;
        if (event.target.type == 'checkbox') {
            this.CustomerRecord[fieldname] = event.target.checked;
        } else if (event.target.type == 'text') {
            this.CustomerRecord[fieldname] = event.target.value;
        } else if (event.target.type == 'email') {

            this.CustomerRecord[fieldname] = event.target.value;
        }
        this.checkRequiredField();
    }

    handleSelectionChange(event) {
        this.CustomerRecord[event.target.name] = event.detail.value; 
        console.log('******* selection change :' + event.target.name + event.detail.value);
        if (event.target.name == 'ASI_eForm_Payment_Method__c' && (event.detail.value == 'Bank Transfer' || event.detail.value == 'Autopay')) {
            this.DisplayBankField = true;
        } else if (event.target.name == 'ASI_eForm_Payment_Method__c' && event.detail.value == 'Cheque') {
            this.DisplayBankField = false;
        }

        if(event.target.name =='ASI_eForm_HK_Category_of_Purchases__c'){
            var PurchasesStr = ' '
            for(var i=0;i<event.detail.value.length ; i++){
                console.log(  event.detail.value[i]);
                PurchasesStr+=event.detail.value[i]+';'
            }
            this.CustomerRecord[event.target.name]  = PurchasesStr;
        }
        this.checkRequiredField();
    }

    handleCheckBoxChange(event) { // T & C checobox change

        if (event.target.name == 'TnC_Chx1') {
            this.TnC_Chx1 = event.target.checked;
        }
        if (event.target.name == 'TnC_Chx2') {
            this.TnC_Chx2 = event.target.checked;
        }
        if (this.TnC_Chx1 && this.TnC_Chx2) {
            this.disabledSubmit = false;
        } else {
            this.disabledSubmit = true;
        }
    }


    resetData() {
        this.TnC_Chx1 = false;
        this.TnC_Chx2 = false;
        this.disabledSubmit = true;
    }

    checkRequiredField() {
        //console.log('check required field');
        if (this.checkValueBlank(this.CustomerRecord['ASI_eForm_Vendor_Name__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Address_Line_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Prefix_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Phone_Fax_Number_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Payment_Method__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Payment_Term__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Contact_Person__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_BR_Certificate_no__c']) &&
            this.emailIsValid(this.CustomerRecord['ASI_eForm_Email__c'])) {

            if (this.DisplayBankField) {
                if (this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_Beneficiary_Name__c']) &&
                    this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_Bank_Name__c']) &&
                    this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_Bank_Code__c']) &&
                    this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_Bank_Address__c']) &&
                    this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_Bank_AC_Num__c']) &&
                    this.checkValueBlank(this.CustomerRecord['ASI_eForm_Webform_SWIFT_Code__c'])) {
                    this.disabledNext1 = false;
                } else {
                    this.disabledNext1 = true;
                }
            } else {
                this.disabledNext1 = false;
                console.log('set to false');
            }

        }
    }


    checkValueBlank(InputValue) {
        if (InputValue && InputValue != '') {
            return true;
        } else {
            return false;
        }
    }
    emailIsValid(email) {
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }
    // ***************** Submit function **********************************
    handleSubmit(event) {
        this.currentStep = "4"; //this.isLoaded = true;
        this.SysInfoDetail = '';
        this.displaySysInfo = true;
        this.ShowProgressIcon = true;
        this.ShowProgress = true;
        this.SysInfoHeader = 'Form Submission';
        this.showingProgress(1);
        var requestOptions = {};

        GenerateRefreshToken().then(result => {
            this.APIobj = JSON.parse(result);
            requestOptions = {
                method: 'PATCH',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this.GeneratingVFBody()),
                redirect: 'follow'
            };
            this.showingProgress(2);
            console.log('***this.APIobj*****');//
            console.log(requestOptions);

            return fetch(this.APIobj.instance_url + "/services/data/v47.0/sobjects/ASI_eForm_Vendor_Form__c/" + this.recordId, requestOptions);

        }).then(result => {
            this.showingProgress(3);
            console.log('*******sObjList updateRecord Done *****'); //this.isLoaded = false;
            console.log(result);
            requestOptions = {
                method: 'PATCH',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: encodeURIComponent(this.BRfileContents),
                redirect: 'follow'
            };
            return fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'Company Registration_' + this.BRFileName, requestOptions);
        }).then(result => {
            this.showingProgress(5);
            if (this.SignatureChopContents) {
                requestOptions = {
                    method: 'PATCH',
                    headers: {
                        'Authorization': 'Bearer ' + this.APIobj.access_token,
                        'X-PrettyPrint': '1',
                        'Content-Type': 'application/json'
                    },
                    body: encodeURIComponent(this.SignatureChopContents),
                    redirect: 'follow'
                };
                return fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'RFI_' + 'SignatureChop_' + this.SignatureChopFileName, requestOptions);
            } else {
                return null;
            }
        }).then(result => {
            if (this.DisplayBankField) {
                this.ProcessBankProof();
            } else {
                console.log(' Finished!!!');
                this.showingProgress(100);
            }


        }).catch(error => {
            console.log('*****failed*******');
            console.log(error);
        });

    }

    ProcessBankProof() {
        this.showingProgress(6);
        var requestOptions = {
            method: 'PATCH',
            headers: {
                'Authorization': 'Bearer ' + this.APIobj.access_token,
                'X-PrettyPrint': '1',
                'Content-Type': 'application/json'
            },
            body: encodeURIComponent(this.BankContents),
            redirect: 'follow'
        };

        fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'Bank_' + this.BankFileName, requestOptions).then(result => {
            this.showingProgress(100);
            console.log(result); //this.SubmissionFinished();
        })
            .catch(error => {
                console.log('*****failed*******');
                console.log(error);
            });
    }

    showingProgress(step) {

        if (this.DisplayBankField) {
            if (step == 1) {
                this.ProgressInfo = 'Progress: Submitting eform.';
                this.progressRate = 0;
            }
            else if (step == 2) {
                this.ProgressInfo = 'Progress 15%: Checking your eForm .';
                this.progressRate = 15;
            }

            else if (step == 3) {
                this.ProgressInfo = 'Progress 40%: Checking your files.';
                this.progressRate = 40;
            }

            else if (step == 4) {
                this.ProgressInfo = 'Progress 60%: uploading files.';
                this.progressRate = 60;
            }
            else if (step == 5) {
                this.ProgressInfo = 'Progress 70%: Process Form.';
                this.progressRate = 70;

            } else if (step == 6) {
                this.ProgressInfo = 'Progress 80%: Process Form.';
                this.progressRate = 80;

            } else if (step == 7) {
                this.ProgressInfo = 'Progress 90%: Process Form.';
                this.progressRate = 90;
            }
        } else {
            if (step == 1) {
                this.ProgressInfo = 'Progress: Submitting eform.';
                this.progressRate = 0;
            }
            else if (step == 2) {
                this.ProgressInfo = 'Progress 25%: Checking your eForm .';
                this.progressRate = 25;
            }

            else if (step == 3) {
                this.ProgressInfo = 'Progress 50%: Checking your files.';
                this.progressRate = 50;
            }

            else if (step == 4) {
                this.ProgressInfo = 'Progress 75%: uploading files.';
                this.progressRate = 75;
            }
            else if (step == 5) {
                this.ProgressInfo = 'Progress 90%: Process Form.';
                this.progressRate = 90;

            } else if (step == 6) {
                this.ProgressInfo = 'Progress 90%: Process Form.';
                this.progressRate = 90;

            }
        }

        if (step == 100) {
            this.ShowProgressIcon = false;
            this.showSuccess = true;
            this.SysInfoHeader = 'Form submitted';
            this.ProgressInfo = 'Thank you for your submission!';
            this.progressRate = 100;//console.log('*******Done*****');
        }

    }


    GeneratingVFBody() {
        console.log('ASI_eForm_HK_Category_of_Purchases__c****8');
        console.log(this.CustomerRecord.ASI_eForm_HK_Category_of_Purchases__c);

        var recordMetadata = {
            'RecordTypeId': '012D0000000t2EoIAI',
            'ASI_eForm_Webform__c': true,
            'ASI_eForm_Status__c': 'Draft',
            'ASI_eForm_Webform_Bank__c': ' Other Bank',
            'ASI_eForm_CAT_Code_15__c' : '901',
            'ASI_eForm_HK_Category_of_Purchases__c': this.CustomerRecord.ASI_eForm_HK_Category_of_Purchases__c ? this.CustomerRecord.ASI_eForm_HK_Category_of_Purchases__c : '',
            'ASI_eForm_HK_Category_of_Purchase_Others__c': this.CustomerRecord.ASI_eForm_HK_Category_of_Purchase_Others__c ? this.CustomerRecord.ASI_eForm_HK_Category_of_Purchase_Others__c : '',
            'ASI_eForm_Business_Nature__c': this.CustomerRecord.ASI_eForm_Business_Nature__c ? this.CustomerRecord.ASI_eForm_Business_Nature__c : '',
            'ASI_eForm_No_of_Branches_Location_s__c': this.CustomerRecord.ASI_eForm_No_of_Branches_Location_s__c ? this.CustomerRecord.ASI_eForm_No_of_Branches_Location_s__c : 0,
            'ASI_eForm_Website__c': this.CustomerRecord.ASI_eForm_Website__c ? this.CustomerRecord.ASI_eForm_Website__c : '',
            'ASI_eForm_No_of_Staff__c': this.CustomerRecord.ASI_eForm_No_of_Staff__c ? this.CustomerRecord.ASI_eForm_No_of_Staff__c : '',
            'ASI_eForm_Year_of_Establishment__c': this.CustomerRecord.ASI_eForm_Year_of_Establishment__c ? this.CustomerRecord.ASI_eForm_Year_of_Establishment__c : '',
            'ASI_eForm_Yearly_Production_Volume__c': this.CustomerRecord.ASI_eForm_Yearly_Production_Volume__c ? this.CustomerRecord.ASI_eForm_Yearly_Production_Volume__c : 0,
            'ASI_eForm_Yearly_Sales_Turnover__c': this.CustomerRecord.ASI_eForm_Yearly_Sales_Turnover__c ? this.CustomerRecord.ASI_eForm_Yearly_Sales_Turnover__c : 0,
            'ASI_eForm_Production_License__c': this.CustomerRecord.ASI_eForm_Production_License__c ? this.CustomerRecord.ASI_eForm_Production_License__c : '',
            'ASI_eForm_Manufacturing_Management_Cert__c': this.CustomerRecord.ASI_eForm_Manufacturing_Management_Cert__c ? this.CustomerRecord.ASI_eForm_Manufacturing_Management_Cert__c : '',
            'ASI_eForm_Production_Goods_Safety_Cert__c': this.CustomerRecord.ASI_eForm_Production_Goods_Safety_Cert__c ? this.CustomerRecord.ASI_eForm_Production_Goods_Safety_Cert__c : '',
            'ASI_eForm_Goods_Quality_Cert__c': this.CustomerRecord.ASI_eForm_Goods_Quality_Cert__c ? this.CustomerRecord.ASI_eForm_Goods_Quality_Cert__c : '',
            'ASI_eForm_Environment_Protection_Cert__c': this.CustomerRecord.ASI_eForm_Environment_Protection_Cert__c ? this.CustomerRecord.ASI_eForm_Environment_Protection_Cert__c : '',
            'ASI_eForm_Other_Remark__c': this.CustomerRecord.ASI_eForm_Other_Remark__c ? this.CustomerRecord.ASI_eForm_Other_Remark__c : '',
            'ASI_eForm_BR_Certificate_no__c': this.CustomerRecord.ASI_eForm_BR_Certificate_no__c ? this.CustomerRecord.ASI_eForm_BR_Certificate_no__c : '',



            'ASI_eForm_Vendor_Name__c': this.CustomerRecord.ASI_eForm_Vendor_Name__c,
            'ASI_eForm_Address_Line_1__c': this.CustomerRecord.ASI_eForm_Address_Line_1__c ? this.CustomerRecord.ASI_eForm_Address_Line_1__c : '',
            'ASI_eForm_Address_Line_2__c': this.CustomerRecord.ASI_eForm_Address_Line_2__c ? this.CustomerRecord.ASI_eForm_Address_Line_2__c : '',
            'ASI_eForm_Address_Line_3__c': this.CustomerRecord.ASI_eForm_Address_Line_3__c ? this.CustomerRecord.ASI_eForm_Address_Line_3__c : '',
            'ASI_eForm_Country__c': this.CustomerRecord.ASI_eForm_Country__c ? this.CustomerRecord.ASI_eForm_Country__c : '',
            'ASI_eForm_Postal_Code__c': this.CustomerRecord.ASI_eForm_Postal_Code__c ? this.CustomerRecord.ASI_eForm_Postal_Code__c : '',
            'ASI_eForm_Contact_Person__c': this.CustomerRecord.ASI_eForm_Contact_Person__c ? this.CustomerRecord.ASI_eForm_Contact_Person__c : '',
            'ASI_eForm_Email__c': this.CustomerRecord.ASI_eForm_Email__c ? this.CustomerRecord.ASI_eForm_Email__c : '',
            'ASI_eForm_Phone_Fax_1__c': this.CustomerRecord.ASI_eForm_Phone_Fax_1__c ? this.CustomerRecord.ASI_eForm_Phone_Fax_1__c : '',
            'ASI_eForm_Prefix_1__c': this.CustomerRecord.ASI_eForm_Prefix_1__c ? this.CustomerRecord.ASI_eForm_Prefix_1__c : '',
            'ASI_eForm_Phone_Fax_Number_1__c': this.CustomerRecord.ASI_eForm_Phone_Fax_Number_1__c ? this.CustomerRecord.ASI_eForm_Phone_Fax_Number_1__c : '',
            'ASI_eForm_Phone_Fax_2__c': this.CustomerRecord.ASI_eForm_Phone_Fax_2__c ? this.CustomerRecord.ASI_eForm_Phone_Fax_2__c : '',
            'ASI_eForm_Prefix_2__c': this.CustomerRecord.ASI_eForm_Prefix_2__c ? this.CustomerRecord.ASI_eForm_Prefix_2__c : '',
            'ASI_eForm_Phone_Fax_Number_2__c': this.CustomerRecord.ASI_eForm_Phone_Fax_Number_2__c ? this.CustomerRecord.ASI_eForm_Phone_Fax_Number_2__c : '',
            'ASI_eForm_Payment_Term__c': this.CustomerRecord.ASI_eForm_Payment_Term__c ? this.CustomerRecord.ASI_eForm_Payment_Term__c : '',
            'ASI_eForm_Payment_Method__c': this.CustomerRecord.ASI_eForm_Payment_Method__c ? this.CustomerRecord.ASI_eForm_Payment_Method__c : '',
            'ASI_eForm_Default_Currency__c': this.CustomerRecord.ASI_eForm_Default_Currency__c ? this.CustomerRecord.ASI_eForm_Default_Currency__c : false,
            'ASI_eForm_Webform_Beneficiary_Name__c': this.CustomerRecord.ASI_eForm_Webform_Beneficiary_Name__c ? this.CustomerRecord.ASI_eForm_Webform_Beneficiary_Name__c : '',
            'ASI_eForm_Webform_Bank_Name__c': this.CustomerRecord.ASI_eForm_Webform_Bank_Name__c ? this.CustomerRecord.ASI_eForm_Webform_Bank_Name__c : '',
            'ASI_eForm_Webform_Bank_Code__c': this.CustomerRecord.ASI_eForm_Webform_Bank_Code__c ? this.CustomerRecord.ASI_eForm_Webform_Bank_Code__c : '',
            'ASI_eForm_Webform_Bank_Address__c': this.CustomerRecord.ASI_eForm_Webform_Bank_Address__c ? this.CustomerRecord.ASI_eForm_Webform_Bank_Address__c : '',
            'ASI_eForm_Webform_Bank_AC_Num__c': this.CustomerRecord.ASI_eForm_Webform_Bank_AC_Num__c ? this.CustomerRecord.ASI_eForm_Webform_Bank_AC_Num__c : '',
            'ASI_eForm_Webform_Bank_Country_Code__c': this.CustomerRecord.ASI_eForm_Webform_Bank_Country_Code__c ? this.CustomerRecord.ASI_eForm_Webform_Bank_Country_Code__c : '',
            'ASI_eForm_Webform_IBAN_Code__c': this.CustomerRecord.ASI_eForm_Webform_IBAN_Code__c ? this.CustomerRecord.ASI_eForm_Webform_IBAN_Code__c : '',
            'ASI_eForm_Webform_Currency__c': this.CustomerRecord.ASI_eForm_Webform_Currency__c ? this.CustomerRecord.ASI_eForm_Webform_Currency__c : '',
            'ASI_eForm_Webform_SWIFT_Code__c': this.CustomerRecord.ASI_eForm_Webform_SWIFT_Code__c ? this.CustomerRecord.ASI_eForm_Webform_SWIFT_Code__c : ''

        };

        console.log('****recordMetadata**');
        console.log(recordMetadata);
        return recordMetadata;
    }

    ShowErrorInfo(ErrorDetail) {
        this.showError = true;
        this.displaySysInfo = true;
        this.SysInfoHeader = 'Error';
        this.SysInfoDetail = ErrorDetail; // 'You already submitted this eform.';
    }


}