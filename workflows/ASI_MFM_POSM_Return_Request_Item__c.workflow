<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_Final_Email_Noti</fullName>
        <description>ASI MFM CN POSM Return Item Final Email Noti</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_POSM_ReturnItem_EFinal</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_A_Status</fullName>
        <field>ASI_MFM_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI MFM CN POSM Return Item A Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_C_Status</fullName>
        <field>ASI_MFM_Approval_Status__c</field>
        <literalValue>Canceled</literalValue>
        <name>ASI MFM CN POSM Return Item C Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_P_Status</fullName>
        <field>ASI_MFM_Approval_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>ASI MFM CN POSM Return Item P Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_POSM_Request_Item_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI MFM CN POSM Return Item RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_R_Status</fullName>
        <field>ASI_MFM_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI MFM CN POSM Return Item R Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_POSM_ReturnItem_Final_Email_Noti</fullName>
        <actions>
            <name>ASI_MFM_CN_POSM_ReturnItem_Final_Email_Noti</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_POSM_Return_Request_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN POSM Request Item,CN POSM Request Item RO</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_POSM_Return_Request_Item__c.ASI_MFM_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved,Rejected,Canceled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_POSM_Return_Request_Item__c.ASI_MFM_Item_Owner__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
