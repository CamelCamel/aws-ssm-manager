#!/bin/bash

TARGET=${1:-false}

echo ""
aws --version
INSTALL_YN=$(echo $?)

if [ "$INSTALL_YN" == 0 ]; then

    # 앱 선택
    if [ $TARGET == false ]; then
        # 예시 서버를 app1, app2 등을 지우고 작성
        echo ""
        echo "HELP: ssm [server alias] / example: ssm app1, ssm app2, ssm pay-app .."
        echo "Input server alias [app1 | app2 | pay-app] >> "
        read TARGET;
    fi

    echo ""
    echo "TARGET IS :"$TARGET

    # 인스턴스 전체 검색
    INSTANCE_ID=$(echo $(aws ec2 describe-tags --filters "Name=value,Values=$TARGET" "Name=resource-type,Values=instance" --query "Tags[*].ResourceId"))
    IDS=$(echo $INSTANCE_ID | sed s/'\[ "'//g | sed s/'" \]'//g | sed s/'", '//g)

    if [ "$INSTANCE_ID" == "[]" ]; then
        echo ""
        echo "non-existent instance"
    else
        # 인스턴스 상태 : running 인 인스턴스 리스트 출력
        INDEX=0
        RIGHT_STATUS=$(echo "[ \"running\" ]")
        REAL_INSTANCE=""

        echo ""
        echo "instance index |     instance ID"
        echo "--------------------------------------"
        for ID in $(echo $IDS | tr '\"' '\n');
        do
            INSTANCE_STATUS=$(echo $(aws ec2 describe-instance-status --instance-id $ID --query "InstanceStatuses[*].InstanceState.Name"))
            if [ "$INSTANCE_STATUS" == "$RIGHT_STATUS" ]; then

                INDEX=$(echo $INDEX + 1 | bc)
                echo  "       $INDEX       |  $ID"
                REAL_INSTANCE=$REAL_INSTANCE,$ID
            fi
        done

        SELECT_INDEX=0

        if [ "$INDEX" == 0 ]; then
            echo ""
            echo "There is no instance running"
        elif [ "$INDEX" == 1 ]; then
            SELECT_ID=$(echo $REAL_INSTANCE | cut -d "," -f2)
            echo ""
            echo "run command >> aws ssm start-session --target $SELECT_ID"
            aws ssm start-session --target $SELECT_ID
        else
            echo ""
            echo "select instance index / example : 1, 2, 3 ..."
            read SELECT_INDEX;

            if [ $SELECT_INDEX -gt $INDEX ]; then
                echo "Invalid index"
            else
                SELECT_ID=$(echo $REAL_INSTANCE | cut -d "," -f$(echo $SELECT_INDEX + 1 | bc))
                echo ""
                echo "run command >> aws ssm start-session --target $SELECT_ID"
                aws ssm start-session --target $SELECT_ID
            fi
        fi
    fi

else
    echo ""
    echo "aws-cli not installed. Please install aws-cli"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    echo ""
    echo ""
fi
