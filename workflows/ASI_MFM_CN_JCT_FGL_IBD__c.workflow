<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Check_Holded_Quantity</fullName>
        <field>ASI_MFM_Holdied_Quantity__c</field>
        <literalValue>1</literalValue>
        <name>ASI_MFM_CN_Check_Holded_Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Uncheck_Holded_Quantity</fullName>
        <field>ASI_MFM_Holdied_Quantity__c</field>
        <literalValue>0</literalValue>
        <name>ASI_MFM_Uncheck_Holded_Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_POSM_InvBalance_Check</fullName>
        <actions>
            <name>ASI_MFM_CN_Check_Holded_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>3 AND 4 AND (1 OR 2 OR 5)</booleanFilter>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN POSM</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FG_ETL__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Approved by Logistic</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_POSM_InvBalance_unCheck</fullName>
        <actions>
            <name>ASI_MFM_Uncheck_Holded_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN POSM</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FGL_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FGL_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Rejected by Logistic</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_CN_JCT_FGL_IBD__c.ASI_MFM_FreeGoodsRequestStatus__c</field>
            <operation>equals</operation>
            <value>Rejected by Finance</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
