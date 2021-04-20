<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_KOR_Payment_Settlement_TMKT_Notification</fullName>
        <description>ASI KOR Payment Settlement TMKT Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_KOR_Business_Development_Admin</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ASI_KOR_Trade_Marketing_Team</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>junnyun.kim@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_NSD_Payment_Settlement_Approved</template>
    </alerts>
    <rules>
        <fullName>ASI KOR NSD Payment Settlement Approved</fullName>
        <actions>
            <name>ASI_KOR_Payment_Settlement_TMKT_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_NSD_Payment_Settlement_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Final Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
