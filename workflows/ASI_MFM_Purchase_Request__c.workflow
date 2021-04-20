<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_PR_KR_Approved_Email_Alert</fullName>
        <description>ASI MFM PR KR Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ASI_KR_Purchasing_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ASI_KR_Purchasing_Team</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_KR_Email_Folder/ASI_MFM_KR_PR_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_PR_KR_Rejected_Email_Alert</fullName>
        <description>ASI MFM PR KR Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_KR_Email_Folder/ASI_MFM_KR_PR_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_MFM_KR_Set_PR_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_KR_Purchase_Request_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI MFM KR Set PR Read-Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_KR_Set_Record_Types_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_KR_Purchase_Request_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI MFM PR KR Set Record Types Read-Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_Set_Status_to_Approved</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI MFM PR Set Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_Set_Status_to_Draft</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI MFM PR Set Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_Set_Status_to_Rejected</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI MFM PR Set Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_Set_Status_to_Submitted</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI MFM PR Set Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_PR_Update_SubmitforApproval</fullName>
        <field>ASI_MFM_Submit_for_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Update Submit for Approval To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_KR_Set_PR_Read_Only</fullName>
        <actions>
            <name>ASI_MFM_KR_Set_PR_Read_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(ASI_MFM_Status__c, &quot;Approved&quot;) &amp;&amp; ISPICKVAL(PRIORVALUE( ASI_MFM_Status__c ), &quot;Draft&quot;)&amp;&amp;(CONTAINS(RecordType.DeveloperName, &quot;ASI_MFM_KR_Purchase_Request&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
