## Reserves

### Reserve altered

| key | value |
| --- | --- |
| borrowingEnabled | ~~false~~true |
| reserveFactor | ~~0~~1500 |


### Raw diff

```json
{
  "reserves": {
    "0xD6DF932A45C0f255f85145f286eA0b292B21C90B": {
      "borrowingEnabled": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 0,
        "to": 1500
      }
    }
  }
}
```