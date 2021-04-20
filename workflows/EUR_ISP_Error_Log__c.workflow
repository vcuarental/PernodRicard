<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_ISP_DE_Error_Log</fullName>
        <ccEmails>therese_ordell@persistent.com</ccEmails>
        <description>EUR_ISP_DE_Error_Log</description>
        <protected>false</protected>
        <recipients>
            <recipient>jan.zimmer@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marc.wunderle@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_ISP_Email_Templates/EUR_ISP_DE_Error_Log_Template</template>
    </alerts>
    <rules>
        <fullName>EUR_ISP_DE_Error_Log</fullName>
        <actions>
            <name>EUR_ISP_DE_Error_Log</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_ISP_Error_Log__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>DE Error Log</value>
        </criteriaItems>
        <description>Will send an email to Philipp Hoffmann if some &quot;push to iSpend error&quot; appears</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
