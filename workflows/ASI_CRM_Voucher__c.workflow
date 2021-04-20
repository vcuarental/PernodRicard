<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_SG_Voucher_Notify_Admin</fullName>
        <description>ASI CRM SG Voucher Notify Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Voucher_Admin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Voucher_Notify_Admin</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Notify_Voucher_Admin_False</fullName>
        <field>ASI_CRM_SYS_Notify_Voucher_Admin__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM SG Notify Voucher Admin False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_SG_Voucher_Notify_Admin</fullName>
        <actions>
            <name>ASI_CRM_SG_Voucher_Notify_Admin</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Notify_Voucher_Admin_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Voucher__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Voucher</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Voucher__c.ASI_CRM_SYS_Notify_Voucher_Admin__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
