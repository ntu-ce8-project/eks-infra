import http from "k6/http";
import { sleep } from "k6";

export const options = {
  cloud: {
    name: "Load test (staging)",
    distribution: {
      singapore: { loadZone: "amazon:sg:singapore", percent: 100 },
    },
  },
};

export default function () {
  http.get("https://quickpizza.grafana.com");
  sleep(1);
}
