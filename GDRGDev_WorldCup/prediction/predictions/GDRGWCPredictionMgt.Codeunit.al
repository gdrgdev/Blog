codeunit 88898 "GDRG WC Prediction Mgt"
{
    Permissions = tabledata "GDRG WC Match" = r,
                   tabledata "GDRG WC Prediction" = rimd;

    internal procedure RefreshPredictionsForUser(UserNameText: Text[100])
    var
        MatchRec: Record "GDRG WC Match";
    begin
        if UserNameText = '' then
            exit;

        if MatchRec.FindSet() then
            repeat
                UpsertPredictionFromMatch(UserNameText, MatchRec);
            until MatchRec.Next() = 0;
    end;


    local procedure UpsertPredictionFromMatch(UserNameText: Text[100]; MatchRec: Record "GDRG WC Match")
    var
        PredictionRec: Record "GDRG WC Prediction";
        ExistingPrediction: Boolean;
    begin
        PredictionRec.SetRange(Username, UserNameText);
        PredictionRec.SetRange("Match Entry No.", MatchRec."Entry No.");
        ExistingPrediction := PredictionRec.FindFirst();

        if not ExistingPrediction then begin
            PredictionRec.Init();
            PredictionRec."Entry No." := GetNextEntryNo();
            PredictionRec.Username := CopyStr(UserNameText, 1, MaxStrLen(PredictionRec.Username));
            PredictionRec."Match Entry No." := MatchRec."Entry No.";
            PredictionRec.Insert(false);
        end;

        PredictionRec."Match Date" := MatchRec."Match Date";
        PredictionRec."Match Time" := MatchRec."Match Time";
        PredictionRec."Match DateTime" := MatchRec."Match DateTime";
        PredictionRec."Team 1" := MatchRec."Team 1";
        PredictionRec."Team 2" := MatchRec."Team 2";
        PredictionRec."Team 1 Score" := MatchRec."Team 1 Score";
        PredictionRec."Team 2 Score" := MatchRec."Team 2 Score";
        PredictionRec."Has Result" := MatchRec."Has Result";
        PredictionRec."Result Type" := MatchRec."Result Type";
        PredictionRec."Match Last Updated At" := MatchRec."Last Updated At";
        PredictionRec.Points := CalculatePoints(PredictionRec."Has Prediction", PredictionRec."Result Type", PredictionRec."Team 1 Score", PredictionRec."Team 2 Score", PredictionRec."Predicted Team 1 Score", PredictionRec."Predicted Team 2 Score");
        PredictionRec."Last Updated At" := CurrentDateTime();

        PredictionRec.Modify(false);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        PredictionRec: Record "GDRG WC Prediction";
    begin
        if PredictionRec.FindLast() then
            exit(PredictionRec."Entry No." + 1);

        exit(1);
    end;

    local procedure CalculatePoints(HasPrediction: Boolean; ResultType: Code[2]; RealTeam1Score: Integer; RealTeam2Score: Integer; PredictedTeam1Score: Integer; PredictedTeam2Score: Integer): Integer
    begin
        if not HasPrediction then
            exit(0);

        if ResultType = '' then
            exit(0);

        if (RealTeam1Score = PredictedTeam1Score) and (RealTeam2Score = PredictedTeam2Score) then
            exit(3);

        if GetOutcome(RealTeam1Score, RealTeam2Score) = GetOutcome(PredictedTeam1Score, PredictedTeam2Score) then
            exit(1);

        exit(0);
    end;

    local procedure GetOutcome(Team1Score: Integer; Team2Score: Integer): Integer
    begin
        if Team1Score > Team2Score then
            exit(1);

        if Team1Score < Team2Score then
            exit(-1);

        exit(0);
    end;
}
