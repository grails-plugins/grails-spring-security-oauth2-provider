package test.oauth2

import grails.testing.gorm.DomainUnitTest
import spock.lang.Ignore
import spock.lang.Specification
import spock.lang.Unroll
import test.oauth2.AuthorizationCode

class AuthorizationCodeSpec extends Specification implements DomainUnitTest<AuthorizationCode> {

    void "require code and authentication"() {
        given:
        def serializedAuthentication = [0x1] as byte[]

        when:
        def authorizationCode = new AuthorizationCode(code: 'foo', authentication: serializedAuthentication)

        then:
        authorizationCode.validate()

        and:
        authorizationCode.code == 'foo'
        authorizationCode.authentication == serializedAuthentication
    }

    void "code must be unique"() {
        given:
        def existingCode = new AuthorizationCode(code: 'foo')

        when:
        def newCode = new AuthorizationCode(code: 'foo')

        then:
        !newCode.validate(['code'])
    }

    @Unroll
    void "invalid code [#code]"() {
        when:
        def authorizationCode = new AuthorizationCode(code: code)

        then:
        !authorizationCode.validate(['code'])

        where:
        code << ['', null]
    }

    @Ignore("grails/grails-core##10786")
    @Unroll
    void "authentication must not be [#auth]"() {
        when:
        def authorizationCode = new AuthorizationCode(authentication: auth as byte[])

        then:
        !authorizationCode.validate(['authentication'])

        where:
        auth << [ null, [] ]
    }
}