import requests
import requests.exceptions
import logging

logger = logging.getLogger("passive")

def send_request(url, connection_timeout, **kwargs):
    """
    Send an HTTP POST request to given url.

    :param url: The URL we want to pull from
    :param kwargs: Extra keywords to be passed to requests.post
    :rtype: requests.models.Response
    """

    try:
        r = requests.post(url, timeout=connection_timeout, data=kwargs, verify=False, allow_redirects=True)
    except requests.exceptions.HTTPError as e:
        logger.error("HTTP Error: %s", e)
    except requests.exceptions.ConnectionError as e:
        logger.error("Connection Error: %s", e)
    except requests.exceptions.Timeout as e:
        logger.error("Connection Timeout: %s", e)
    except Exception as ex:
        logger.exception(ex)
    else:
        logger.debug('Content response from URL: %s' % str(r.content))
        return r.content

    return None
