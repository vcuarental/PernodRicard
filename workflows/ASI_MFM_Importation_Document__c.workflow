<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_MFM_CN_Importation_Doc_Approved_Alert</fullName>
        <description>CN Importation Doc Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>andy.jiang@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_Importation_Document_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_Importation_Doc_Rejected_Alert</fullName>
        <description>CN Importation Doc Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_Importation_Document_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_ImporDoc_Uncheck_Submit_Flag</fullName>
        <field>ASI_MFM_Allow_Submit__c</field>
        <literalValue>0</literalValue>
        <name>CN ImporDoc Uncheck Submit Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_ImportationDoc_Set_Editable</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Importation_Document</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN ImportationDoc Set Editable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_ImportationDoc_Set_ReadOnly</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_Importation_Document_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN ImportationDoc Set ReadOnly</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Importation_Doc_SetSubmitted</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CN Importation Doc Set Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Importation_Doc_Set_Draft</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CN Importation Doc Set Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Importation_Doc_Set_Final</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Final</literalValue>
        <name>CN Importation Doc Set Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
