<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_ZA_Send_POSM_Order_to_SR</fullName>
        <description>EUR ZA Send POSM Order to SR</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_ZA_Email_Templates/EUR_CRM_ZA_POSm_Request_Change_Notification_to_SR</template>
    </alerts>
    <alerts>
        <fullName>EUR_ZA_Send_POSM_Order_to_Warehouse_Manager</fullName>
        <description>EUR ZA Send POSM Order to Warehouse Manager</description>
        <protected>false</protected>
        <recipients>
            <field>EUR_CRM_Warehouse_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_ZA_Email_Templates/EUR_CRM_ZA_POSM_Request_Notification_to_Warehouse_Manager</template>
    </alerts>
    <rules>
        <fullName>EUR ZA POSM Order to SR</fullName>
        <actions>
            <name>EUR_ZA_Send_POSM_Order_to_SR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_POSM_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR ZA POSM Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_POSM_Order__c.EUR_CRM_Order_Status__c</field>
            <operation>equals</operation>
            <value>Finished,Cancelled,Partially processed</value>
        </criteriaItems>
        <description>Notify the Sales Rep, through email, that a POSM Order has been modified.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA POSM Order to Warehouse Manager</fullName>
        <actions>
            <name>EUR_ZA_Send_POSM_Order_to_Warehouse_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the Warehouse Manager, through email, that a new POSM Order has been created in JDE.</description>
        <formula>AND( ISPICKVAL(EUR_CRM_Order_Status__c, &apos;In process&apos;),  RecordType.DeveloperName = &apos;EUR_ZA_POSM_Order&apos;, OR( NOT(ISPICKVAL(PRIORVALUE(EUR_CRM_Order_Status__c),&apos;In process&apos;)), ISCHANGED( EUR_CRM_Warehouse_Manager__c ), ISNEW() ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
