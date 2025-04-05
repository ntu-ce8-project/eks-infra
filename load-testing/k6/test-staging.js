import tempo from "https://jslib.k6.io/http-instrumentation-tempo/1.0.0/index.js";
import http from "k6/http";
import { sleep } from "k6";

// instrumentHTTP ensures requests made by the http module will have a trace context attached
tempo.instrumentHTTP({
  propagator: "w3c",
});

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
