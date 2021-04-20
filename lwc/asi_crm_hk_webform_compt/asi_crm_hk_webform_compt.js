import { LightningElement, api, track } from 'lwc';

import fetchsObjectData from '@salesforce/apex/ASI_eForm_HK_CustomerFormController.fetchsObjectData';

import GenerateRefreshToken from '@salesforce/apex/ASI_eForm_HK_CustomerFormController.GenerateRefreshToken';


import HK_LOGO from '@salesforce/resourceUrl/ASI_CRM_HK_Logo';
import PRA_LOGO from '@salesforce/resourceUrl/ASI_eForm_PRA_Logo';
import ATR_LOGO from '@salesforce/resourceUrl/ASI_eForm_ATR_Logo';

export default class Asi_crm_hk_webform_compt extends LightningElement {
    @api recordId;
    @api formType;
    @api source;
    @track CompanyName = '';
    @track LogId = '';
    @track CompanyShortName = '';
    @track APIobj = {};
    @track formHeadLogoUrl;
    @track disabledSubmit = true;
    @track disabledNext1 = true;
    @track disabledNext2 = true;
    @track TnC_Chx1 = false;
    @track TnC_Chx2 = false;
    //@track allowSubmit = false;
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

    @track DisplayEmail2 = false;
    @track DisplayEmail3 = false;
    @track DisplayEmail4 = false;
    @track DisplayEmail5 = false;

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

    @track BankCountry = [
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
    ]

    MAX_FILE_SIZE = 3000000; // 5000000   
    fileReader;

    BRfileContents;
    SChopfileContents; //Signature Chop
    DChopfileContents; //Delivery Chop
    BankProoffileContents; // Bank Proof
    @track BRFileName = '';
    @track SignatureChopFileName = '';
    @track DeliveryChopFileName = '';
    @track BankProofFileName = '';
    OwnerEmail = '';
    @track CSRFormURL = '';

    //fileContents;



    renderedCallback() {

        if (this.Initialized) {
            return;
        }
        this.Initialized = true;//console.log('load 20200418.03');
        Promise.all([
            //load js lib
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
        console.log(' v1.0 source : ' + this.source);
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
        //var sqlstr = "Select Id ,ASI_eForm_Submit__c,ASI_eForm_Payment_Method__c,ASI_eForm_Owner_Email__c from ASI_eForm_Customer_Form__c where id='" + this.recordId + "'";
        // fetchsObjectData({ soqlStatement: sqlstr }).then(result => {


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

            return fetch(this.APIobj.instance_url + "/services/data/v47.0/sobjects/ASI_eForm_Customer_Form__c/" + this.recordId, requestOptions);
        }).then(response => response.text()).then(result => {
            var resultObj = JSON.parse(result);

            if (resultObj.ASI_eForm_Submit__c) { // true, not allow to open form  //this.displaySysInfo = true;    //this.SysInfoHeader = 'Error'; //this.SysInfoDetail = 'You already submitted this eform.';
                this.ShowErrorInfo('You already submitted this eform.');
                this.currentStep = '4';
            } else {
                //this.FormOwner = result[0].Owner.Name;
                this.OwnerEmail = resultObj.ASI_eForm_Owner_Email__c;
                console.log('email : ' + this.OwnerEmail);
                this.CustomerRecord.ASI_eForm_Payment_Method__c = resultObj.ASI_eForm_Payment_Method__c;
                this.CustomerRecord.ASI_eForm_Bank_Currency__c = 'HKD-Hong Kong - Hong Kong Dollar';
                this.CustomerRecord.ASI_eForm_Bank_Country__c = 'HK-HONG KONG';
                this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c = true;//this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c = false;
                this.CustomerRecord.ASI_eForm_Payment_Method__c = 'Bank Transfer';
                this.DisplayBankField = true;
            }
            this.isLoaded = false;
            var sqlstr = 'select id,ASI_eForm_HK_CSR_form_URL__c from ASI_MFM_Setting__c';
            return fetchsObjectData({ soqlStatement: sqlstr });
        }).then(result => {
            this.CSRFormURL = result[0].ASI_eForm_HK_CSR_form_URL__c;

            if (this.source == 'email') {
                GenerateRefreshToken().then(result => {
                    this.APIobj = JSON.parse(result);
                    var requestOptions = {
                        method: 'PATCH',
                        headers: {
                            'Authorization': 'Bearer ' + this.APIobj.access_token,
                            'X-PrettyPrint': '1',
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({ 'ASI_eForm_Status__c': 'Link Activated' }),
                        redirect: 'follow'
                    };
                    fetch(this.APIobj.instance_url + "/services/data/v47.0/sobjects/ASI_eForm_Customer_Form__c/" + this.recordId, requestOptions);
                });
            }
        }).catch(error => {
            console.log('***** fetchsObjectData failed*******');
            this.displaySysInfo = true;
            this.SysInfoHeader = 'Error';
            this.SysInfoDetail = error;
            this.showError = true;
            console.log(error);
        });

    }




    handleUpload(event) {
        console.log(' ** handleUpload ** '); //console.log(event);console.log(event.target.files);  console.log('name : ' + event.target.files[0].name);

        this.showError = false;
        this.displaySysInfo = false;
        var inputId = event.target.id;
        var filename = event.target.files[0].name; // var filename = ''; //var filename = event.target.files[0].name;
        var filesize = event.target.files[0].size;

        this.fileReader = new FileReader();
        console.log('Size : ' + filesize + '   id : ' + event.target.id);
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
            }
            else if (inputId.includes("Upload_Company_Signature_Chop")) {
                this.SChopfileContents = fileContents;
                this.SignatureChopFileName = filename;
            }
            else if (inputId.includes("Upload_Company_Delivery_Chop")) {
                this.DChopfileContents = fileContents;
                this.DeliveryChopFileName = filename;
            }
            else if (inputId.includes("Upload_Bank_Proof")) {
                this.BankProoffileContents = fileContents;
                this.BankProofFileName = filename;
            }

            if (this.BRfileContents && this.SChopfileContents && this.DChopfileContents) {
                if (this.DisplayBankField && !this.BankProoffileContents) {
                    this.disabledNext2 = true;
                }
                else {
                    this.disabledNext2 = false;
                }
            } else {
                this.disabledNext1 = true;
            }
            this.handleFilechanges(filename, fileContents);
        });
        this.fileReader.readAsDataURL(event.target.files[0]);
    }

    handleFilechanges(FN, fileContent) {
        console.log('LogId : ' + this.LogId);
        if (this.LogId != '') {
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
                fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.LogId + ':' + FN, requestOptions);
            }).catch(error => {
                console.log('*****failed*******');
                console.log(error);
            });
        }
    }

    //********** status******************** */
    get DisplayPreviousButton() { // 2 3 
        return this.currentStep === "2" || this.currentStep === "3";
    }
    get Page1() {
        return this.currentStep === "1";
    }
    get Page2() {
        return this.currentStep === "2";
    }
    get DisplayNextButton() {
        return this.currentStep === "1" || this.currentStep === "2";
    }
    get DisplayCustomerInformation() {
        return this.currentStep === "1";
    }
    get DisplayUploadAttachment() {
        return this.currentStep === "2";
    }
    get DisplaySummary() {
        return this.currentStep === "3";
    }


    //******** handle Input or checkbox or button changes  *************** */

    handleFormInputChange(event) { // input field change

        var fieldname = event.currentTarget.dataset.field;
        if (event.target.type == 'checkbox') {
            this.CustomerRecord[fieldname] = event.target.checked;
        }
        else if (event.target.type == 'text') {
            this.CustomerRecord[fieldname] = event.target.value;
        } else if (event.target.type == 'email') {
            this.CustomerRecord[fieldname] = event.target.value;
        }


        if (fieldname === 'ASI_eForm_Customer_Name__c') {
            this.CustomerRecord[fieldname] = this.CustomerRecord[fieldname].replace(/,/g, "");
        }
        //check required field

        if (fieldname === 'ASI_eForm_Create_Vendor_Account__c') {
            if (!event.target.checked) {
                this.DisplayBankField = false;
            }
        }


        if (fieldname === 'ASI_eForm_Delivery_Address_Different__c') {
            this.DisplayDeliveryField = event.target.checked;
        }

        if (fieldname === 'ASI_eForm_e_Statement_for_Email_2__c' && this.CustomerRecord[fieldname]) {
            this.DisplayEmail2 = true;
        } else if (fieldname === 'ASI_eForm_e_Statement_for_Email_2__c' && !this.CustomerRecord[fieldname]) {
            this.DisplayEmail2 = false;
        }

        if (fieldname === 'ASI_eForm_e_Statement_for_Email_3__c' && this.CustomerRecord[fieldname]) {
            this.DisplayEmail3 = true;
        } else if (fieldname === 'ASI_eForm_e_Statement_for_Email_3__c' && !this.CustomerRecord[fieldname]) {
            this.DisplayEmail3 = false;
        }
        if (fieldname === 'ASI_eForm_e_Statement_for_Email_4__c' && this.CustomerRecord[fieldname]) {
            this.DisplayEmail4 = true;
        } else if (fieldname === 'ASI_eForm_e_Statement_for_Email_4__c' && !this.CustomerRecord[fieldname]) {
            this.DisplayEmail4 = false;
        }
        if (fieldname === 'ASI_eForm_e_Statement_for_Email_5__c' && this.CustomerRecord[fieldname]) {
            this.DisplayEmail5 = true;
        } else if (fieldname === 'ASI_eForm_e_Statement_for_Email_5__c' && !this.CustomerRecord[fieldname]) {
            this.DisplayEmail5 = false;
        }
        this.checkRequiredField();
    }


    handleSelectionChange(event) { // selection change
        console.log('handleSelectionChange : ' + event.target.name + event.detail.value);
        this.CustomerRecord[event.target.name] = event.detail.value;
        if (event.target.name == 'ASI_eForm_Payment_Method__c' && event.detail.value != 'Cheque') {
            this.DisplayBankField = true;
        } else if (event.target.name == 'ASI_eForm_Payment_Method__c' && event.detail.value == 'Cheque') {
            this.DisplayBankField = false;
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
        if (this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c) {
            if (this.TnC_Chx1 && this.TnC_Chx2) {
                this.disabledSubmit = false;
            } else {
                this.disabledSubmit = true;
            }
        } else {
            if (this.TnC_Chx1) {
                this.disabledSubmit = false;
            } else {
                this.disabledSubmit = true;
            }
        }

    }


    resetData() {
        this.TnC_Chx1 = false;
        this.TnC_Chx2 = false;
        this.disabledSubmit = true;
    }
    emailIsValid(email) {
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }

    checkRequiredField() {
        if (this.checkValueBlank(this.CustomerRecord['ASI_eForm_Customer_Name__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Contact_Person_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Phone_Contact_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Country_Code_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_Address_Line_1__c']) &&
            this.checkValueBlank(this.CustomerRecord['ASI_eForm_BR_Certificate_no__c'])) {

            if (!this.DisplayBankField) {
                this.disabledNext1 = false;
            } else if (this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c) {
                if (this.checkValueBlank(this.CustomerRecord['ASI_eForm_Payment_Method__c'])) {
                    if (this.checkValueBlank(this.CustomerRecord['ASI_eForm_Banks_Name__c']) &&
                        this.checkValueBlank(this.CustomerRecord['ASI_eForm_Bank_Address__c']) &&
                        this.checkValueBlank(this.CustomerRecord['ASI_eForm_Bank_Account_No__c'])) {
                        this.disabledNext1 = false;
                    } else {// failed
                        this.disabledNext1 = true;
                    }
                } else {// failed
                    this.disabledNext1 = true;
                }
            }
            else {
                this.disabledNext1 = true;
            }
        } else {
            this.disabledNext1 = true;
        }

        if (((this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_2__c']) && !this.emailIsValid(this.CustomerRecord['ASI_eForm_Email_2__c'])) || !this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_2__c'])) && this.DisplayEmail2) {
            this.disabledNext1 = true;
        }
        if (((this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_3__c']) && !this.emailIsValid(this.CustomerRecord['ASI_eForm_Email_3__c'])) || !this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_3__c'])) && this.DisplayEmail3) {
            this.disabledNext1 = true;
        }
        if (((this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_4__c']) && !this.emailIsValid(this.CustomerRecord['ASI_eForm_Email_4__c'])) || !this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_4__c'])) && this.DisplayEmail4) {
            this.disabledNext1 = true;
        }
        if (((this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_5__c']) && !this.emailIsValid(this.CustomerRecord['ASI_eForm_Email_5__c'])) || !this.checkValueBlank(this.CustomerRecord['ASI_eForm_Email_5__c'])) && this.DisplayEmail5) {
            this.disabledNext1 = true;
        }

    }

    checkValueBlank(InputValue) {
        if (InputValue && InputValue != '') {
            return true;
        } else {
            return false;
        }
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
                "ASI_CRM_Customer_Form__c": this.recordId
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
            return fetch(this.APIobj.instance_url + "/services/data/v20.0/sobjects/ASI_MFM_Mass_Upload_Log__c/", requestOptions);
        }).then(res => {
            return res.json();
        }).then(result => {
            if (result.success) {
                this.LogId = result.id;
            }
        }).catch(error => {
            console.log('*****failed*******');
            console.log(error);
        });
    }


    GeneratingCFBody() {
        if (this.CustomerRecord.ASI_eForm_Customer_Name__c.length > 40) {
            this.CustomerRecord.ASI_eForm_Beneficiary_Name__c = this.CustomerRecord.ASI_eForm_Customer_Name__c.substring(0, 40);
        } else {
            this.CustomerRecord.ASI_eForm_Beneficiary_Name__c = this.CustomerRecord.ASI_eForm_Customer_Name__c;
        }
        var recordMetadata = {
            'RecordTypeId': '0121i000000g5jXAAQ',
            'ASI_eForm_Submit__c': true,
            'ASI_eForm_Webform__c': true,
            'ASI_eForm_Status__c': 'Draft',
            'ASI_eForm_Vendor_Payment_Terms__c': ' 030-Open A/C 30 Days',
            'ASI_eForm_Vendor_Currency__c': 'HKD',
            'ASI_eForm_Vendor_MFM_Access_CC15__c': '901',
            'ASI_eForm_Vendor_Payment_Class_Code__c': 'DISC',
            'ASI_eForm_Vendor_Search_Type__c': 'V - Non-Trade Vendor',
            'ASI_eForm_Bank__c': 'Other Bank',

            'ASI_eForm_Beneficiary_Name__c': this.CustomerRecord.ASI_eForm_Beneficiary_Name__c,
            'ASI_eForm_Customer_Name__c': this.CustomerRecord.ASI_eForm_Customer_Name__c,
            'ASI_eForm_Contact_Person_1__c': this.CustomerRecord.ASI_eForm_Contact_Person_1__c ? this.CustomerRecord.ASI_eForm_Contact_Person_1__c : '',
            'ASI_eForm_Phone_Contact_1__c': this.CustomerRecord.ASI_eForm_Phone_Contact_1__c ? this.CustomerRecord.ASI_eForm_Phone_Contact_1__c : '',
            'ASI_eForm_Country_Code_1__c': this.CustomerRecord.ASI_eForm_Country_Code_1__c ? this.CustomerRecord.ASI_eForm_Country_Code_1__c : '',
            'ASI_eForm_Fax_Contact__c': this.CustomerRecord.ASI_eForm_Fax_Contact__c ? this.CustomerRecord.ASI_eForm_Fax_Contact__c : '',
            'ASI_eForm_Country_Code_fax__c': this.CustomerRecord.ASI_eForm_Country_Code_fax__c ? this.CustomerRecord.ASI_eForm_Country_Code_fax__c : '',

            'ASI_eForm_Business_Nature__c': this.CustomerRecord.ASI_eForm_Business_Nature__c ? this.CustomerRecord.ASI_eForm_Business_Nature__c : '',
            'ASI_eForm_No_of_Branches_Location__c': this.CustomerRecord.ASI_eForm_No_of_Branches_Location__c ? this.CustomerRecord.ASI_eForm_No_of_Branches_Location__c : 0,
            'ASI_eForm_Website__c': this.CustomerRecord.ASI_eForm_Website__c ? this.CustomerRecord.ASI_eForm_Website__c : '',
            'ASI_eForm_No_of_Staff__c': this.CustomerRecord.ASI_eForm_No_of_Staff__c ? this.CustomerRecord.ASI_eForm_No_of_Staff__c : '',
            'ASI_eForm_Year_of_Establishment__c': this.CustomerRecord.ASI_eForm_Year_of_Establishment__c ? this.CustomerRecord.ASI_eForm_Year_of_Establishment__c : '',

            'ASI_eForm_Address_Country__c': this.CustomerRecord.ASI_eForm_Address_Country__c ? this.CustomerRecord.ASI_eForm_Address_Country__c : '',
            'ASI_eForm_Address_Postal_Code__c': this.CustomerRecord.ASI_eForm_Address_Postal_Code__c ? this.CustomerRecord.ASI_eForm_Address_Postal_Code__c : '',
            'ASI_eForm_Business_Branch_Name__c': this.CustomerRecord.ASI_eForm_Business_Branch_Name__c ? this.CustomerRecord.ASI_eForm_Business_Branch_Name__c : '',
            'ASI_eForm_e_Statement_for_Email_2__c': this.CustomerRecord.ASI_eForm_e_Statement_for_Email_2__c ? this.CustomerRecord.ASI_eForm_e_Statement_for_Email_2__c : false,
            'ASI_eForm_Email_2__c': this.CustomerRecord.ASI_eForm_Email_2__c ? this.CustomerRecord.ASI_eForm_Email_2__c : '',
            'ASI_eForm_e_Statement_for_Email_3__c': this.CustomerRecord.ASI_eForm_e_Statement_for_Email_3__c ? this.CustomerRecord.ASI_eForm_e_Statement_for_Email_3__c : false,
            'ASI_eForm_Email_3__c': this.CustomerRecord.ASI_eForm_Email_3__c ? this.CustomerRecord.ASI_eForm_Email_3__c : '',
            'ASI_eForm_e_Statement_for_Email_4__c': this.CustomerRecord.ASI_eForm_e_Statement_for_Email_4__c ? this.CustomerRecord.ASI_eForm_e_Statement_for_Email_4__c : false,
            'ASI_eForm_Email_4__c': this.CustomerRecord.ASI_eForm_Email_4__c ? this.CustomerRecord.ASI_eForm_Email_4__c : '',
            'ASI_eForm_e_Statement_for_Email_5__c': this.CustomerRecord.ASI_eForm_e_Statement_for_Email_5__c ? this.CustomerRecord.ASI_eForm_e_Statement_for_Email_5__c : false,
            'ASI_eForm_Email_5__c': this.CustomerRecord.ASI_eForm_Email_5__c ? this.CustomerRecord.ASI_eForm_Email_5__c : '',

            'ASI_eForm_Address_Line_1__c': this.CustomerRecord.ASI_eForm_Address_Line_1__c ? this.CustomerRecord.ASI_eForm_Address_Line_1__c : '',
            'ASI_eForm_Address_Line_2__c': this.CustomerRecord.ASI_eForm_Address_Line_2__c ? this.CustomerRecord.ASI_eForm_Address_Line_2__c : '',
            'ASI_eForm_Address_Line_3__c': this.CustomerRecord.ASI_eForm_Address_Line_3__c ? this.CustomerRecord.ASI_eForm_Address_Line_3__c : '',
            'ASI_eForm_Delivery_Address_Different__c': this.CustomerRecord.ASI_eForm_Delivery_Address_Different__c ? this.CustomerRecord.ASI_eForm_Delivery_Address_Different__c : false,
            'ASI_eForm_BR_Certificate_no__c': this.CustomerRecord.ASI_eForm_BR_Certificate_no__c ? this.CustomerRecord.ASI_eForm_BR_Certificate_no__c : '',
            'ASI_eForm_Create_Vendor_Account__c': this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c ? this.CustomerRecord.ASI_eForm_Create_Vendor_Account__c : false,
            'ASI_eForm_Banks_Name__c': this.CustomerRecord.ASI_eForm_Banks_Name__c ? this.CustomerRecord.ASI_eForm_Banks_Name__c : '',
            'ASI_eForm_Payment_Method__c': this.CustomerRecord.ASI_eForm_Payment_Method__c ? this.CustomerRecord.ASI_eForm_Payment_Method__c : '',
            'ASI_eForm_Bank_Address__c': this.CustomerRecord.ASI_eForm_Bank_Address__c ? this.CustomerRecord.ASI_eForm_Bank_Address__c : '',
            'ASI_eForm_Bank_Country__c': this.CustomerRecord.ASI_eForm_Bank_Country__c ? this.CustomerRecord.ASI_eForm_Bank_Country__c : '',
            'ASI_eForm_Swift_Code__c': this.CustomerRecord.ASI_eForm_Swift_Code__c ? this.CustomerRecord.ASI_eForm_Swift_Code__c : '',
            'ASI_eForm_IBAN_Code__c': this.CustomerRecord.ASI_eForm_IBAN_Code__c ? this.CustomerRecord.ASI_eForm_IBAN_Code__c : '',
            'ASI_eForm_Bank_Currency__c': this.CustomerRecord.ASI_eForm_Bank_Currency__c ? this.CustomerRecord.ASI_eForm_Bank_Currency__c : '',
            'ASI_eForm_Bank_Account_No__c': this.CustomerRecord.ASI_eForm_Bank_Account_No__c ? this.CustomerRecord.ASI_eForm_Bank_Account_No__c : ''


        };


        if (recordMetadata.ASI_eForm_Delivery_Address_Different__c) {
            recordMetadata.ASI_eForm_Delivery_Address_1__c = this.CustomerRecord.ASI_eForm_Delivery_Address_1__c ? this.CustomerRecord.ASI_eForm_Delivery_Address_1__c : '';
            recordMetadata.ASI_eForm_Delivery_Address_2__c = this.CustomerRecord.ASI_eForm_Delivery_Address_2__c ? this.CustomerRecord.ASI_eForm_Delivery_Address_2__c : '';
            recordMetadata.ASI_eForm_Delivery_Address_3__c = this.CustomerRecord.ASI_eForm_Delivery_Address_3__c ? this.CustomerRecord.ASI_eForm_Delivery_Address_3__c : '';
        
    }
        return recordMetadata;
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
        var collectedRecord = this.GeneratingCFBody();
        console.log(JSON.stringify(collectedRecord));
        GenerateRefreshToken().then(result => {
            this.APIobj = JSON.parse(result);
            requestOptions = {
                method: 'PATCH',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(collectedRecord),
                redirect: 'follow'
            };
            return fetch(this.APIobj.instance_url + "/services/data/v47.0/sobjects/ASI_eForm_Customer_Form__c/" + this.recordId, requestOptions);
        }).then(result => {
            this.showingProgress(2);
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
            return fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'BR_' + this.BRFileName, requestOptions);//return saveFile({ idParent: this.recordId, strFileName: 'BR_' + this.BRFileName, base64Data: encodeURIComponent(this.BRfileContents) });
        }).then(result => {
            this.showingProgress(3);
            requestOptions = {
                method: 'PATCH',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: encodeURIComponent(this.SChopfileContents),
                redirect: 'follow'
            };
            return fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'Signature Chop_' + this.SignatureChopFileName, requestOptions);//return saveFile({ idParent: this.recordId, strFileName: 'Signature Chop_' + this.SignatureChopFileName, base64Data: encodeURIComponent(this.SChopfileContents) });
        }).then(result => {
            this.showingProgress(4);
            requestOptions = {
                method: 'PATCH',
                headers: {
                    'Authorization': 'Bearer ' + this.APIobj.access_token,
                    'X-PrettyPrint': '1',
                    'Content-Type': 'application/json'
                },
                body: encodeURIComponent(this.DChopfileContents),
                redirect: 'follow'
            };
            return fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'Delivery Chop_' + this.DeliveryChopFileName, requestOptions);//return saveFile({ idParent: this.recordId, strFileName: 'Delivery Chop_' + this.DeliveryChopFileName, base64Data: encodeURIComponent(this.DChopfileContents) });
        }).then(result => {

            this.showingProgress(5);
            if (this.DisplayBankField) {
                this.ProcessBankProof();
            }
            else {
                this.showingProgress(9);//this.ProcessFlow();
                console.log('*******Done*****');
                console.log(result); //this.SubmissionFinished();
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
            body: encodeURIComponent(this.BankProoffileContents),
            redirect: 'follow'
        };//saveFile({ idParent: this.recordId, strFileName: 'Bank Proof_' + this.BankProofFileName, base64Data: encodeURIComponent(this.BankProoffileContents) })

        fetch(this.APIobj.instance_url + "/services/apexrest/ASI_eForm_HK_eFormAPI/" + this.recordId + ':' + 'Bank Proof_' + this.BankProofFileName, requestOptions).then(result => {
            this.showingProgress(9);
            //this.ProcessFlow();
            console.log(result); //this.SubmissionFinished();
        })
            .catch(error => {
                console.log('*****failed*******');
                console.log(error);
            });
    }


    showingProgress(step) {
        var CreateVendorFlag = this.DisplayBankField;
        console.log('upload step ' + step);
        if (step == 1) {
            this.ProgressInfo = 'Progress: Submitting eform.';
            this.progressRate = 0;
        }
        else if (step == 2 && !CreateVendorFlag) {
            this.ProgressInfo = 'Progress 20%: uploading files (1/3).';
            this.progressRate = 25;
        }

        else if (step == 3 && !CreateVendorFlag) {
            this.ProgressInfo = 'Progress 50%: uploading files (2/3).';
            this.progressRate = 50;
        }

        else if (step == 4 && !CreateVendorFlag) {
            this.ProgressInfo = 'Progress 75%: uploading files (3/3).';
            this.progressRate = 75;
        }
        else if (step == 5 && !CreateVendorFlag) {
            this.ProgressInfo = 'Progress 90%: Process Form.';
            this.progressRate = 90;

        }
        //********************** */
        else if (step == 2 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 25%: uploading files (1/4).';
            this.progressRate = 20;
        }
        else if (step == 3 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 40%: uploading files (2/4).';
            this.progressRate = 40;
        }

        else if (step == 4 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 60%: uploading files (3/4).';
            this.progressRate = 60;
        }
        else if (step == 5 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 80%: uploading files (4/4).';
            this.progressRate = 80;

        }
        else if (step == 5 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 80%: uploading files (4/4).';
            this.progressRate = 80;
        }
        else if (step == 6 && CreateVendorFlag) {
            this.ProgressInfo = 'Progress 90%: Process eForm.';
            this.progressRate = 90;
        }

        //*************Final Step************** */
        else if (step == 9) {
            this.ShowProgressIcon = false;
            this.showSuccess = true;
            this.SysInfoHeader = 'Form submitted';
            this.ProgressInfo = 'Thank you for your submission!';
            this.progressRate = 100;
            console.log('*******Done*****');
        }


    }


    ShowErrorInfo(ErrorDetail) {
        this.showError = true;
        this.displaySysInfo = true;
        this.SysInfoHeader = 'Error';
        this.SysInfoDetail = ErrorDetail; // 'You already submitted this eform.';
    }


}