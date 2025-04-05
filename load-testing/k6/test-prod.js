import tempo from "https://jslib.k6.io/http-instrumentation-tempo/1.0.0/index.js";
import { sleep, group } from "k6";
import http from "k6/http";

// Requests made by the http module will have a trace context attached
tempo.instrumentHTTP({
  propagator: "w3c",
});

const BASE_URL = "http://shop.sctp-sandbox.com";

export const options = {
  cloud: {
    name: "User makes purchase (prod)",
    distribution: {
      "amazon:sg:singapore": { loadZone: "amazon:sg:singapore", percent: 100 },
    },
    apm: [],
  },
  thresholds: { http_req_duration: ["p(95)<=500"] },
  scenarios: {
    Scenario: {
      executor: "ramping-vus",
      gracefulStop: "30s",
      stages: [
        { target: 10, duration: "1m" },
        { target: 20, duration: "3m" },
        { target: 0, duration: "1m" },
      ],
      gracefulRampDown: "30s",
      exec: "scenario",
    },
  },
};

export function scenario() {
  let response;

  group("Cart - user adds item to cart", function () {
    response = http.post(
      `${BASE_URL}/cart`,
      {
        productId: "a1258cd2-176c-4507-ade6-746dab5ad625",
      },
      {
        headers: {
          "content-type": "application/x-www-form-urlencoded",
          origin: BASE_URL,
          "upgrade-insecure-requests": "1",
        },
      }
    );
    sleep(1);
  });

  group("Checkout - user checks out", function () {
    response = http.get(`${BASE_URL}/checkout`, {
      headers: {
        "upgrade-insecure-requests": "1",
      },
    });
    sleep(1);

    response = http.post(
      `${BASE_URL}/checkout`,
      {
        firstName: "John",
        lastName: "Doe",
        streetAddress: "100 Main Street",
        city: "Anytown",
        state: "CA",
        zipCode: "11111",
        email: "john_doe@example.com",
      },
      {
        headers: {
          "content-type": "application/x-www-form-urlencoded",
          origin: BASE_URL,
          "upgrade-insecure-requests": "1",
        },
      }
    );
    sleep(1);
  });

  group("Delivery - user selects delivery", function () {
    response = http.post(
      `${BASE_URL}/checkout/delivery`,
      {
        token: "priority-mail",
      },
      {
        headers: {
          "content-type": "application/x-www-form-urlencoded",
          origin: BASE_URL,
          "upgrade-insecure-requests": "1",
        },
      }
    );
    sleep(1);
  });

  group("Payment - user makes payment", function () {
    response = http.post(
      `${BASE_URL}/checkout/payment`,
      {
        cardHolder: "John Doe",
        cardNumber: "1234567890123456",
        expiryDate: "01/35",
        cvc: "123",
      },
      {
        headers: {
          "content-type": "application/x-www-form-urlencoded",
          origin: BASE_URL,
          "upgrade-insecure-requests": "1",
        },
      }
    );
  });
}

export default function () {
  scenario();
}
