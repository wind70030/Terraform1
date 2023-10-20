## 이 프로젝트는 EKS와 RDS를 테라폼으로 구성하는 테라폼 코드임
## 또, 구성된 EKS에 AWS ALB Controller를 설치하는 내용과
## 아르고CD를 이용한 CI를 구성하는 내용이 포함되어 있음

1. EKS와 RDS를 생성하는 테라폼 코드
   - "Terraform1" 프로젝트의 테라폼 코드를 실행하면 EKS와 RDS가 구성됨
   * eks terraform code 참조 사이트
     - https://github.com/HanHoRang31/T101-Terraform-EKS/blob/main/1.Building-EKS-with-Terraform/01-ekscluster-terraform-manifests/c5-08-eks-node-group-private.tf

2. Git 명령과 관련된 Tip
   - Remote origin already exists 에러 발생 시 처리 방법
     - #git remote remove origin
     - #git remote add origin [새롭게 연결할 깃 레파지토리 주소]
     - #git remote -v
     - #git commit -m "comment"
     - #git push origin main
   - .terraform화일을 git push에서 제외하는 방법
     - #git filter-branch -f --index-filter 'git rm --cached -r --ignore-unmatch .terraform/'
   - git push나 pull했을 때 "fatal: refusing to merge unrelated histories" error 발생 시 조치 방법
     - #git pull origin [branch name] --allow-unrelated-histories 


2. Argocd 설치 방법
   1) Argocd yaml intall 방법
      - #kubectl create namespace argocd
      - #kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   2) argocd 외부 접속 포인트 설정 방법
      - #kubectl get service -n argocd 
      - #kubectl edit svc argocd-server -n argocd
      - "type: ClusterIP"를  ->  "type: NodePort"   또는  "type: LoadBalancer"로  변경
   3) argocd password 확인 방법
      - #kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -data
      - or
      - https://www.base64decode.org/에 접속하여 "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}""로 나온 인코딩 값을 디코딩함
   4) argocd에서 github 연동 방법(https://minha0220.tistory.com/113 참고)
      - 가. key 생성
          #ssh-keygen -t ed25519 -C "your_email@example.com"
      - 나. ssh-agent를 백그라운드에서 실행(git bash에서 실행해야 함)
          #eval "$(ssh-agent -s)"
      다. ssh-agent에 SSH 프라이빗 키를 추가(git bash에서 실행해야 함)
          #ssh-add ~/.ssh/id_ed25519
      라. C:/사용자/pc/.ssh/id_ed25519.pub 내용 copy
      마. 이 퍼블릭 키를 복사해서 Github > Settings > SSH and GPG keys > New SSH key 에 추가
    5) arcocd ingress 적용 방법 참조
       https://developnote-blog.tistory.com/171

3. kubectl로 EKS 접근하기 위한 config 작업
   - #aws configure
   - kubectl이 eks에 연동 안될 때 처리 방법
     #aws eks --region ap-northeast-2 update-kubeconfig --name SAP-terraform-eks

5. EKS에 AWS ALB Controller를 설치
   1) IAM OIDC Provider 생성
      #eksctl utils associate-iam-oidc-provider --region ap-northeast-2 --cluster SAP-terraform-eks --approve
   2) ALB에 대한 정책 다운로드
      #curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
   3) ALB 정책 설정
      #aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
   4) Service Account 생성 및 AWS LoadBalancer Controller IAM 역할 연결(CloudFormation에 있는 stack 삭제 후 Service Account 생성해라.)
      #eksctl create iamserviceaccount --cluster=SAP-terraform-eks --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::XXXXXXXXXXX:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --region ap-northeast-2 --approve
   4-1) LoadBalancer Controller 생성확인 방법
        #kubectl get sa aws-load-balancer-controller -n kube-system
   5) 인증서 관리자 설치
      #kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
   6) AWS Loadbalancer Controller Pod 설치
      #helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=SAP-terraform-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
   7) 생성한 controller pod 확인
      #kubectl -n kube-system get pods | grep balancer)
   8) aws alb 적용 예제 app
      가. #kubectl create namespace test-ing-alb
      나. #kubectl apply -f ./test-app-service.yaml
      다. #kubectl get pod -n test-ing-alb
      라. #kubectl apply -f ./test-ingress.yaml
      마. #kubectl get ing -n test-ing-alb
   9) AWS ALB Controller 삭제 방법
      가. #helm uninstall aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system
      나. #kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
      다. #eksctl delete iamserviceaccount --cluster SAP-terraform-eks --name aws-load-balancer-controller --namespace kube-system --wait
      라. #aws management console에서 AWSLoadBalancerControllerIAMPolicy 삭제
      마. aws management console에서 IAM OIDC Provider 삭제
      바. aws management console에서 CloudFormation에 있는 stack 삭제
