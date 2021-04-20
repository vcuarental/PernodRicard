<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_CN_POSM_ImageUpload_NotifyIT_Alert</fullName>
        <description>ASI_MFM_CN_POSM_ImageUpload_NotifyIT_Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_MFM_CN_POSM_ImageUpload_IT</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_POSM_ImageUpload</template>
    </alerts>
    <rules>
        <fullName>ASI_MFM_CN_POSM_ImageUpload_NotifyIT</fullName>
        <actions>
            <name>ASI_MFM_CN_POSM_ImageUpload_NotifyIT_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_BatchLog__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Batch Log</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_BatchLog__c.ASI_MFM_LogType__c</field>
            <operation>equals</operation>
            <value>POSM Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_BatchLog__c.ASI_MFM_Operation_Error__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
