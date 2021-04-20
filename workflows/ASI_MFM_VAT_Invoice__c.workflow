<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_CN_InvoiceCreationEmailAlert</fullName>
        <description>CN InvoiceCreationEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_MFM_PO_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_InvoiceCreationEmailTemp</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_InvoiceCreationEmailAlert_Emarket</fullName>
        <description>CN InvoiceCreationEmailAlert(Emarket)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_MFM_CN_Invoice_Alert_Emarket</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_InvoiceCreationEmailTemp</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_VAT_Notify_Alert</fullName>
        <description>ASI_MFM_CN_VAT_Notify_Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_VAT_Notify_Procurement_Users</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_VAT_Notify_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_GetRemarkFromPO</fullName>
        <field>ASI_MFM_PO_Remarks__c</field>
        <formula>ASI_MFM_PO_No__r.ASI_MFM_Remarks__c</formula>
        <name>CN GetRemarkFromPO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_InvoiceCreationEmail</fullName>
        <actions>
            <name>ASI_MFM_CN_InvoiceCreationEmailAlert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_MFM_CN_GetRemarkFromPO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN VAT Invoice</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.ASI_MFM_PO_Type__c</field>
            <operation>notEqual</operation>
            <value>eMarket</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_InvoiceCreationEmail%28Emarket%29</fullName>
        <actions>
            <name>ASI_MFM_CN_InvoiceCreationEmailAlert_Emarket</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_MFM_CN_GetRemarkFromPO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN VAT Invoice</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.ASI_MFM_PO_Type__c</field>
            <operation>equals</operation>
            <value>eMarket</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_VAT_Notify_Procurement</fullName>
        <actions>
            <name>ASI_MFM_CN_VAT_Notify_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN VAT Invoice</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_VAT_Invoice__c.ASI_MFM_PO_Type__c</field>
            <operation>equals</operation>
            <value>eMarket</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
