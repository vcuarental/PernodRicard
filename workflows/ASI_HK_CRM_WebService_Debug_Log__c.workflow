<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_SOA_Exception_Alert</fullName>
        <description>ASI SOA Exception Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_SOA_User_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SOA_User_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SOA_User_3__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SOA_User_4__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_SOA_Email_Folder/ASI_SOA_Exception_Email</template>
    </alerts>
    <rules>
        <fullName>ASI_SOA_ExceptionAlert_Rule</fullName>
        <actions>
            <name>ASI_SOA_Exception_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_WebService_Debug_Log__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI SOA Exception Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
