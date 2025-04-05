from locust import HttpUser, task

class LoadTestingUser(HttpUser):
    @task
    def home(self):
        self.client.get("/")
    
    @task
    def catalog(self):
        self.client.get("/catalog")
    
    @task
    def cart(self):
        self.client.get("/cart")
    
    @task
    def checkout(self):
        self.client.get("/checkout")
    
    @task
    def topology(self):
        self.client.get("/topology")