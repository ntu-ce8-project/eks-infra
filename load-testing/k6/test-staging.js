import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  cloud: {
    name: 'Load test (staging)',
  }
};

export default function() {
  http.get('https://quickpizza.grafana.com');
  sleep(1);
}