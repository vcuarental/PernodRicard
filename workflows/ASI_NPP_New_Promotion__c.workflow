<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_NPP_SG_New_Promotion_Approved_Alert</fullName>
        <description>New Promotion Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>kimheng.chua@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>stephen.son@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>winnie.chong@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_NPP_Email_Folder/ASI_NPP_SG_New_Promotion_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_NPP_SG_New_Promotion_Rejected_Alert</fullName>
        <description>New Promotion Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_NPP_Email_Folder/ASI_NPP_SG_New_Promotion_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_NPP_Update_Status_Draft</fullName>
        <field>ASI_NPP_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Status - Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_NPP_Update_Status_Final</fullName>
        <field>ASI_NPP_Status__c</field>
        <literalValue>Final</literalValue>
        <name>Update Status - Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_NPP_Update_Status_Submitted</fullName>
        <field>ASI_NPP_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Status - Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
