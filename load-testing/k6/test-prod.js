import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  cloud: {
    name: "Load test (prod)",
    distribution: {
      singapore: { loadZone: "amazon:sg:singapore", percent: 100 },
    },
  },
};

export default function() {
  http.get("https://postman-echo.com/get?hello=world");
  sleep(1);
}