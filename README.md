### Облачные и кластерные технологии
#### Итоговая курсовая зачетная работа Развертывание инфраструктуры в кластере K8s”


Шаг 1. (Блок 1) Подготовка инфраструктуры

Инфраструктура развернута в yandex cloud с помощью terraform.

Файлы конфигурации в директории [/terraform](./terraform/).

Разделены на логические файлы:
- k8s.tf - конфиги k8s
- main.tf - базовые
- nas.tf - конфиг сервера с nfs
- variables.tf - переменные, используемые в конфигах
- outputs.tf - экспорт созданных значений

Также используется файл
terraform.tfvars, в котором указаны значения переменных, добавлен в gitignore.

Итого:
![alt text](files/image.png)
![alt text](files/image-1.png)
![alt text](files/image-2.png)
![alt text](files/image-3.png)

Кластер в lens:
![alt text](files/image-4.png)

Шаг 2. (Блок 2) Установка ingress
```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace nginx-ingress
helm install nginx-ingress ingress-nginx/ingress-nginx -n nginx-ingress
```

Шаг 3. (Блок 4) Развертывание mariadb-galera
```shell
kubectl create namespace db-cluster
helm repo add bitnami https://charts.bitnami.com/bitnami  
helm repo update
helm install mariadb-cluster bitnami/mariadb --namespace db-cluster \
  -f mariadb/values.yaml \
  -f env.yaml
```
Использовался чарт от bitnami. Кастомные значения занесены в  [mariadb/values.yaml](./helm/mariadb/values.yaml). В файле env.yaml, занесенном в gitignore, лежат чувствительные данные, такие как пароли.

Шаг 4. (Блок 5) Развертывание кластера redis
```shell
helm install redis-cluster bitnami/redis --namespace db-cluster  -f redis/values.yaml
```
Использовался чарт от bitnami. Кастомные значения занесены в  [redis/values.yaml](./helm/redis/values.yaml). В файле env.yaml, занесенном в gitignore, лежат чувствительные данные, такие как пароли.

![alt text](files/image-5.png)

Шаг 5. (Блок 6.1) Подключение NAS как нового StorageClass в K8s

- nfs-server развернут вручную на [виртуалке](./terraform/nas.tf).
- добавлен [storageclass.yaml](./helm/app/templates/storageclass.yaml)

![alt text](files/image-6.png)

Шаг 6. (Блок 7.1) Написание helm чарта и деплой приложения

Чарт создан
```
helm create app
```

Описанный helm чарт расположен в директории [helm/app](./helm/app/)

Добавлен pvc, который успешно был provisioned для NAS сервера.
![alt text](files/image-7.png)

Установка
```shell
kubectl create namespace app
helm install ctfd app --namespace app  
```

Разворачивается две реплики
![alt text](files/image-8.png)

В env.yaml подключаются секреты.
К galera и redis подключение таким образом:
```
- name: DATABASE_URL
      value: "mysql+pymysql://{user}:{pass}@mariadb-cluster-headless.db-cluster.svc.cluster.local:3306/appdb?charset=utf8mb4"

- name: REDIS_URL
      value: "redis://:{pass}@redis-cluster-master.db-cluster.svc.cluster.local:6379/0"
```

Приложение отвечает, если запрашивать его через ingress external IP
![alt text](files/image-9.png)