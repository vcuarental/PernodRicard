<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_DE_New_Convivio_SKU</fullName>
        <ccEmails>conviviosku@mailinator.com</ccEmails>
        <description>EUR DE New Convivio SKU</description>
        <protected>false</protected>
        <recipients>
            <recipient>marcelo.caponi@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DE_Email_Template/EUR_DE_New_SKU</template>
    </alerts>
    <alerts>
        <fullName>EUR_DE_New_Convivio_and_SC_SKU</fullName>
        <ccEmails>conviviosku@mailinator.com,conviviosc@mailinator.com</ccEmails>
        <description>EUR DE New Convivio and SC SKU</description>
        <protected>false</protected>
        <recipients>
            <recipient>marcelo.caponi@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DE_Email_Template/EUR_DE_New_SKU</template>
    </alerts>
    <alerts>
        <fullName>EUR_DE_New_Service_Cloud_SKU</fullName>
        <ccEmails>conviviosc@mailinator.com</ccEmails>
        <description>EUR DE New Service Cloud SKU</description>
        <protected>false</protected>
        <recipients>
            <recipient>marcelo.caponi@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DE_Email_Template/EUR_DE_New_SKU</template>
    </alerts>
    <alerts>
        <fullName>EUR_IDL_SKU_Product_Deactivation</fullName>
        <description>EUR IDL SKU Product Deactivation</description>
        <protected>false</protected>
        <recipients>
            <recipient>sinead.devries@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EUR_CRM_IDL_Email_Templates/EUR_IDL_Product_Inactivity_Notification</template>
    </alerts>
    <rules>
        <fullName>EUR DE New Convivio SKU</fullName>
        <actions>
            <name>EUR_DE_New_Convivio_SKU</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE SKU</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.EUR_CRM_Product_Usage__c</field>
            <operation>equals</operation>
            <value>Convivio</value>
        </criteriaItems>
        <description>If Product Usage value is Convivio, the email is sent to the Convivio Admin</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR DE New Convivio and SC SKU</fullName>
        <actions>
            <name>EUR_DE_New_Convivio_and_SC_SKU</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE SKU</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.EUR_CRM_Product_Usage__c</field>
            <operation>equals</operation>
            <value>Convivio and Service Cloud</value>
        </criteriaItems>
        <description>If Product Usage value is Convivio and Service Cloud, the email is sent to Convivio Admin and the Service Cloud Admin</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR DE New Service Cloud SKU</fullName>
        <actions>
            <name>EUR_DE_New_Service_Cloud_SKU</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE SKU</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.EUR_CRM_Product_Usage__c</field>
            <operation>equals</operation>
            <value>Service Cloud</value>
        </criteriaItems>
        <description>If Product Usage value is Service Cloud, the email is sent to the Service Cloud Admin</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR IDL SKU Product deactivation</fullName>
        <actions>
            <name>EUR_IDL_SKU_Product_Deactivation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.EUR_CRM_Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_SKU__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IDL SKU</value>
        </criteriaItems>
        <description>sends an email to an affiliate admin when a product becomes inactive</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
