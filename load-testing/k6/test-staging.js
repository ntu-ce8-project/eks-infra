import http from "k6/http";
import { sleep } from "k6";

export const options = {
  cloud: {
    name: "Load test (staging)",
    distribution: {
      singapore: { loadZone: "amazon:sg:singapore", percent: 80 },
      paris: { loadZone: "amazon:fr:paris", percent: 20 },
    },
  },
};

export default function () {
  http.get("https://quickpizza.grafana.com");
  sleep(1);
}
