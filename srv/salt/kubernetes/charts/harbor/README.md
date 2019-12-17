# Harbor

![Harbor logo](https://raw.githubusercontent.com/goharbor/harbor/master/docs/img/harbor_logo.png)

Project Harbor is an an open source trusted cloud native registry project that stores, signs, and scans content. Harbor extends the open source Docker Distribution by adding the functionalities usually required by users such as security, identity and management. Having a registry closer to the build and run environment can improve the image transfer efficiency. Harbor supports replication of images between registries, and also offers advanced security features such as user management, access control and activity auditing.

### temporary fix

Enforce `apps/v1` in templates/nginx/deployment.

Will be fixed in next harbor-helm release.

## Reference

* <https://github.com/goharbor/harbor>
* <https://github.com/goharbor/harbor-helm>