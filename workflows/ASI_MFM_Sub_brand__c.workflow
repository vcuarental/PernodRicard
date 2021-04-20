<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_SG_Subbrand_Creation_Email_Alert</fullName>
        <description>ASI CRM SG Subbrand Creation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Wine_Category_Admin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Subbrand_Creation_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Update_Segment_Type</fullName>
        <field>ASI_CRM_VN_Segment_Type__c</field>
        <literalValue>Value</literalValue>
        <name>ASI CRM VN Update Segment Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_SG_Subbrand_Creation</fullName>
        <actions>
            <name>ASI_CRM_SG_Subbrand_Creation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Sub_brand__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Sub-brand</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
