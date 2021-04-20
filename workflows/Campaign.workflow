<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_BRD_Generic_Campaign_RecType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_BRD_Generic_CRM_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI BRD Generic Campaign RecType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_HK_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_HK_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX HK Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_JP_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_JP_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX JP Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_MY_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_MY_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX MY Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_REG_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_Regional_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX REG Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_SG_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_SG_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX SG Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_LUX_TW_Campaign_RecordType_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_LUX_TW_Campaign</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI LUX TW Campaign RecordType Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI LUX HK Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_HK_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>HKG_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX JP Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_JP_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>JPN_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX MY Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_MY_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>MYA_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>notContain</operation>
            <value>_BRD_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX REG Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_REG_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>ASI_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX SG Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_SG_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 5) AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>SGN_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>notContain</operation>
            <value>TGL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>notContain</operation>
            <value>GHM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>SGP_</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI LUX TW Campaign RecordType Conversion</fullName>
        <actions>
            <name>ASI_LUX_TW_Campaign_RecordType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>startsWith</operation>
            <value>TWN_</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI LUX</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_BRD_Generic_Update_Campaign_RecordType</fullName>
        <actions>
            <name>ASI_BRD_Generic_Campaign_RecType_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>ASI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>_BRD_</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
