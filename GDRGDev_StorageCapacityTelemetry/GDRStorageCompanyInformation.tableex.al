tableextension 80000 GDRStorageCompanyInformation extends "Company Information"
{
    fields
    {
        field(80000; GDRStorageEnvironmentsCount; Integer)
        {
            Caption = '% Number of environments';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(80001; GDRStorageTotal; Integer)
        {
            Caption = '% Total environments capacity';
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
}
